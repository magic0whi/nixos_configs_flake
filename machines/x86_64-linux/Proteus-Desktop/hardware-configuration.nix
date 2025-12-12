{modulesPath, config, ...}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "nvme" "usbhid" "uas" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];
  boot.zfs.forceImportRoot = false; # Disable backwards compatibility options
  boot.zfs.allowHibernation = true; # Make sure not use Swap on ZFS

  # Disable zfs-mount, use NixOS systemd mount management
  # Ref: https://wiki.nixos.org/wiki/ZFS#ZFS_conflicting_with_systemd
  systemd.services.zfs-mount.enable = false;

  # disko will take care of filesystems.*, swapDevices, boot.resumeDevice, boot.initrd.luks.devices

  environment.etc."crypttab".text = let
    sata1 = "ata-ST500DM002-1BD142_S2A7EA2P";
    sata2 = "ata-WDC_WD5000AAKX-001CA0_WD-WMAYU5316042";
    sata3 = "ata-WDC_WD5000AAKX-60U6AA0_WD-WCC2E3HEXA48";
    sata4 = "ata-ST1000DM003-1CH162_S1DE5CWF";
    sata5 = "ata-ST1000LM048-2E7172_WKPEZYSN";
    sata6 = "ata-WDC_WD2002FYPS-02W3B0_WCAVY6186321";
    mnt_opts = "nofail,luks,discard,no-read-workqueue,no-write-workqueue";
    key_file = "/persistent/etc/dm_keyfile.key";
  in ''
    crypted-${sata1} /dev/disk/by-id/${sata1}-part1 ${key_file} ${mnt_opts}
    crypted-${sata2} /dev/disk/by-id/${sata2}-part1 ${key_file} ${mnt_opts}
    crypted-${sata3} /dev/disk/by-id/${sata3}-part1 ${key_file} ${mnt_opts}
    crypted-${sata4} /dev/disk/by-id/${sata4}-part1 ${key_file} ${mnt_opts}
    crypted-${sata5} /dev/disk/by-id/${sata5}-part1 ${key_file} ${mnt_opts}
    crypted-${sata6} /dev/disk/by-id/${sata6}-part1 ${key_file} ${mnt_opts}
  '';

  networking.useDHCP = true;
  networking.hostId = "953b2f69"; # ZFS requires this

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
}
