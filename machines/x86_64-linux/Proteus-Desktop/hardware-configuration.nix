{
  config,
  lib,
  modulesPath,
  myvars,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "nvme" "usbhid" "uas" "sd_mod" "r8169"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];
  boot.zfs.forceImportRoot = false; # Disable backwards compatibility options
  boot.zfs.unsafeAllowHibernation = true; # Make sure not use Swap on ZFS

  # Disable zfs-mount, use NixOS systemd mount management
  # Ref: https://wiki.nixos.org/wiki/ZFS#ZFS_conflicting_with_systemd
  systemd.services.zfs-mount.enable = false;

  # disko will take care of filesystems.*, swapDevices, boot.resumeDevice, boot.initrd.luks.devices

  # boot.initrd.network.enable = true;
  boot.initrd.systemd.network.enable = true;
  boot.initrd.systemd.network = {
    networks."10-wired" = {
      matchConfig.Name = "en*";
      DHCP = "yes";
      # Force the interface to require IPv4 specifically to be considered "online"
      linkConfig.RequiredForOnline = "routable";
    };
  };
  # environment.systemPackages = [pkgs.clevis];
  boot.initrd.clevis = let
    disks = [
      "ata-ST500DM002-1BD142_S2A7EA2P"
      "ata-WDC_WD5000AAKX-001CA0_WD-WMAYU5316042"
      "ata-WDC_WD5000AAKX-60U6AA0_WD-WCC2E3HEXA48"
      "ata-ST1000DM003-1CH162_S1DE5CWF"
      "ata-ST1000LM048-2E7172_WKPEZYSN"
      "ata-WDC_WD2002FYPS-02W3B0_WCAVY6186321"
    ];
  in {
    enable = true;
    useTang = true;
    # devices = lib.genAttrs' disks (
    # disk_id:
    # lib.nameValuePair "crypted-${disk_id}" {secretFile = "${myvars.secrets_dir}/Proteus-Desktop.storage.jwe";}
    # );
    devices = lib.listToAttrs (lib.imap0 (idx: disk_id: {
        name = "crypted-${disk_id}";
        value = {secretFile = "${myvars.secrets_dir}/Proteus-Desktop.disk_${toString idx}.jwe";};
      })
      disks);
  };
  boot.initrd.systemd.services = let
    disks = [
      "ata-ST500DM002-1BD142_S2A7EA2P"
      "ata-WDC_WD5000AAKX-001CA0_WD-WMAYU5316042"
      "ata-WDC_WD5000AAKX-60U6AA0_WD-WCC2E3HEXA48"
      "ata-ST1000DM003-1CH162_S1DE5CWF"
      "ata-ST1000LM048-2E7172_WKPEZYSN"
      "ata-WDC_WD2002FYPS-02W3B0_WCAVY6186321"
    ];
  in
    # Makes each cryptsetup-clevis service wait for the previous one to finish
    lib.listToAttrs (lib.imap0 (idx: disk: {
        name = "cryptsetup-clevis-crypted-${disk}";
        value = lib.optionalAttrs (idx > 0) {
          after = ["cryptsetup-clevis-crypted-${builtins.elemAt disks (idx - 0)}.service"];
        };
      })
      disks);
  # environment.etc.crypttab.text = let
  #   satas = [
  #     "ata-ST500DM002-1BD142_S2A7EA2P"
  #     "ata-WDC_WD5000AAKX-001CA0_WD-WMAYU5316042"
  #     "ata-WDC_WD5000AAKX-60U6AA0_WD-WCC2E3HEXA48"
  #     "ata-ST1000DM003-1CH162_S1DE5CWF"
  #     "ata-ST1000LM048-2E7172_WKPEZYSN"
  #     "ata-WDC_WD2002FYPS-02W3B0_WCAVY6186321"
  #   ];
  #   mnt_opts = "nofail,luks,discard,no-read-workqueue,no-write-workqueue";
  #   key_file = "/persistent/etc/dm_keyfile.key"; # TODO: Unsafe
  # in
  #   lib.concatLines (map (disk_id: "crypted-${disk_id} /dev/disk/by-id/${disk_id}-part1 ${key_file} ${mnt_opts}") satas);

  networking.useDHCP = true;
  networking.hostId = "953b2f69"; # ZFS requires this

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
}
