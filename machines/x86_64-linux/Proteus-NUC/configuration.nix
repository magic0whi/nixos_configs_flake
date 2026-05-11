{pkgs, config, lib, ...}: {
  time.timeZone = "Europe/London";
  ## BEGIN iwd.nix
  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings.General.Country = "GB";
  systemd.services.iwd.serviceConfig.ExecStart = [
    "" # Leave a empty to remove previous ExecStarts
    "${config.networking.wireless.iwd.package}/libexec/iwd --nointerfaces 'wlan[0-9]'"
  ];
  systemd.network.links."80-iwd".enable = false; # Or
  # environment.etc."systemd/network/80-iwd.link".source = lib.mkForce (mylib.mk_out_of_store_symlink "/dev/null");
  ## END iwd.nix
  # virtualisation.docker.storageDriver = "btrfs"; # conflict with feature: containerd-snapshotter
  hardware.graphics.extraPackages = with pkgs; [intel-media-driver intel-compute-runtime-legacy1];
  environment.systemPackages = with pkgs; [
    bpftrace # powerful tracing tool, ref: https://github.com/bpftrace/bpftrace
  ];
  ## BEGIN sriov.nix
  boot.extraModulePackages = with pkgs; [i915-sriov xe-sriov];
  boot.kernelParams = [
    "intel_iommu=on"
    # Gen11
    "i915.enable_guc=3"
    "i915.max_vfs=7"
    "module_blacklist=xe"
    # Gen12 and later
    # "xe.max_vfs=7"
    # "xe.force_probe=0x9a60" # cat /sys/devices/pci0000:00/0000:00:02.0/device
    # "module_blacklist=i915"
  ];
  ## END sriov.nix
  ## BEGIN binfmt.nix
  boot.binfmt.emulatedSystems = ["riscv64-linux" "aarch64-linux"]; # Cross compilation
  boot.binfmt.registrations."riscv64-linux" = {
    interpreter = "${lib.getExe' pkgs.pkgsStatic.qemu-user "qemu-riscv64"}";
    fixBinary = true;
    wrapInterpreterInShell = false;
  };
  ## END binfmt.nix
}
