{pkgs, lib, config, ...}: {
  ## START docker.nix
  # =============================================================================
  # Docker + sing-box auto_redirect & FakeIP Conflict Resolution
  # =============================================================================
  # Background:
  #   sing-box runs a TUN interface with auto_redirect (TProxy-like) and FakeIP
  #   (198.18.0.0/15) alongside Docker (172.18.0.0/16). A prior fix (96146a7d)
  #   had disabled auto_redirect entirely to resolve a TProxy vs. Docker NAT
  #   conflict. The following config re-enables it correctly.
  #
  # Root Cause of the Original Conflict:
  #   sing-box's TProxy hooks prerouting at `dstnat - 1`, intercepting container
  #   traffic BEFORE Docker's POSTROUTING MASQUERADE NAT, breaking outbound
  #   container connectivity. Bypassing container IPs at routing level broke
  #   FakeIP, since fake IPs sent to the host kernel were dropped as unroutable.
  #
  # Fix 1: bypass_docker nftables chain:
  #   Inserted at `prerouting priority dstnat - 5` (ahead of sing-box's hook).
  #   Tags all container-sourced traffic with the sing-box bypass mark
  #   (ct mark 0x00002024), letting Docker's native NAT handle it normally.
  #
  #   Critical exception: traffic destined for FakeIP (198.18.0.0/15) hits a
  #   `return` BEFORE the bypass mark, so TProxy can still catch and resolve
  #   those connections.
  networking.nftables.tables.bypass_docker = lib.mkIf config.services.sing-box.enable {
    family = "inet";
    content = ''
      chain prerouting {
        type filter hook prerouting priority dstnat - 5; policy accept;

        # 1. Do NOT bypass FakeIP traffic. Let sing-box handle it.
        ip daddr 198.18.0.0/15 return

        # 2. Bypass everything else from Docker & Libvirt
        ip saddr { 172.18.0.0/16, 192.168.122.1/24 } ct mark set 0x00002024
      }
    '';
  };
  # Fix 2: extraInputRules:
  #   With auto_redirect enabled, sing-box allocates a dynamic local TCP port
  #   and installs several nft rules. Because `redirect` rewrites the packet
  #   destination to the host, traffic finally enters the INPUT chain. But
  #   nixos-fw's default-drop INPUT policy silently dropped these packets.
  #   Accepting 172.18.0.0/16 on INPUT covers all Docker bridge subnets
  #   regardless of bridge name or port changes across restarts.
  # =============================================================================
  networking.firewall.extraInputRules = lib.mkIf config.services.sing-box.enable ''
    ip saddr { 172.18.0.0/16 } accept comment "Allow Docker containers to reach auto_redirect ports"
  '';
  networking.firewall.trustedInterfaces = ["virbr0"];
  systemd.services.docker.path = [pkgs.nftables];
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      firewall-backend = "nftables"; # Requires >= docker 29
      # Enables pulling using containerd, which supports restarting from a
      # partial pull, ref https://docs.docker.com/storage/containerd/
      features = {containerd-snapshotter = true;};
    };
  };
  ## END docker.nix
  # virtualisation.waydroid.enable = true; Usage: https://wiki.nixos.org/wiki/Waydroid
  ## START libvirtd.nix
  # Enable nested virtualization, required by security containers and nested vm.
  # This should be set per host in /hosts, not here.
  # - For AMD CPU, add "kvm-amd" to kernelModules.
  #   boot.kernelModules = ["kvm-amd"];
  #   boot.extraModprobeConfig = "options kvm_amd nested=1"; # for amd cpu
  # - For Intel CPU, add "kvm-intel" to kernelModules.
  #   boot.kernelModules = ["kvm-intel"];
  #   boot.extraModprobeConfig = "options kvm_intel nested=1"; # for intel cpu
  # boot.kernelModules = ["vfio-pci"];
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
      qemu.vhostUserPackages = [pkgs.virtiofsd];
      hooks.qemu."99-hugepages.sh" = pkgs.writeShellScript "99-hugepages.sh" ''
        #!/usr/bin/env bash
        # ## START DEBUG
        # LOG=/var/log/libvirt/hooks-qemu.log
        # exec >>"$LOG" 2>&1
        # set -x
        # echo "---- $(date -Is) ----"
        # echo "argv: $0 $*"
        # env | sort
        # ## END DEBUG
        set -eufo pipefail

        DOMAIN_XML="$(cat)"
        VM="$1"
        OP="$2"
        SUBOP="$3"

        [ "$VM" = "win11" ] || exit 0 # Only for this VM

        MEM_MIB=$((
          $(printf '%s' "$DOMAIN_XML" \
          | ${lib.getExe' pkgs.libxml2 "xmllint"} --xpath "string(//domain/memory)" -) / 1024
        )) # Unit in xml is KiB
        HP_SIZE_KB=$(${lib.getExe pkgs.gawk} '/Hugepagesize:/ { print $2 }' /proc/meminfo)
        HP_SYSFS="/sys/kernel/mm/hugepages/hugepages-''${HP_SIZE_KB}kB/nr_hugepages"

        STATE_DIR="/run/libvirt-hugepages"
        STATE_FILE="$STATE_DIR/$VM.baseline"

        pages_needed() {
          echo $(((MEM_MIB * 1024) / HP_SIZE_KB))
        }

        get_current() {
          cat "$HP_SYSFS"
        }

        set_target() {
          local target="$1"
          echo "$target" > "$HP_SYSFS"
        }

        alloc_if_needed() {
          mkdir -p "$STATE_DIR"

          local baseline current need target
          current="$(get_current)"
          baseline="$current"
          echo "$baseline" > "$STATE_FILE"

          need="$(pages_needed)"
          target=$((baseline + need))

          # Only grow pool if we don't already have enough
          if [ "$current" -lt "$target" ]; then
            set_target "$target"
          fi
        }

        restore_baseline() {
          [ -f "$STATE_FILE" ] || exit 0
          local baseline
          baseline="$(cat "$STATE_FILE")"

          # Restore exactly to what it was before starting this VM
          set_target "$baseline"
          rm -f "$STATE_FILE"
        }

        case "$OP $SUBOP" in
          "prepare begin")
            alloc_if_needed
            ;;
          "release end")
            restore_baseline
            ;;
        esac
      '';
    };
    spiceUSBRedirection.enable = true;
    # lxd.enable = true;
  };
  environment.systemPackages = with pkgs; [
    # This script is used to install the arm translation layer for waydroid
    # so that we can install arm apks on x86_64 waydroid
    # https://github.com/casualsnek/waydroid_script
    # https://github.com/AtaraxiaSjel/nur/tree/master/pkgs/waydroid-script
    # https://wiki.archlinux.org/title/Waydroid#ARM_Apps_Incompatible
    # nur-ataraxiasjel.packages.${pkgs.system}.waydroid-script

    # Need to add [File (in the menu bar) -> Add connection] when start for the first time
    virt-manager

    # QEMU/KVM (HostCpuOnly), provides:
    # - qemu-storage-daemon qemu-edid qemu-ga
    #   qemu-pr-helper qemu-nbd elf2dmp qemu-img qemu-io
    #   qemu-kvm qemu-system-x86_64 qemu-system-aarch64 qemu-system-i386
    # qemu_kvm

    # QEMU (other architectures), provides:
    #   qemu-loongarch64 qemu-system-loongarch64
    #   qemu-riscv64 qemu-system-riscv64 qemu-riscv32 qemu-system-riscv32
    #   qemu-system-arm qemu-arm qemu-armeb qemu-system-aarch64 qemu-aarch64 qemu-aarch64_be
    #   qemu-system-xtensa qemu-xtensa qemu-system-xtensaeb qemu-xtensaeb
    #   ......
    # qemu
  ];
  ## END libvirtd.nix
}
