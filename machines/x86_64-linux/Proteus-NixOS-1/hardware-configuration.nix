{modulesPath, ...}: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  # boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod"];
  boot.initrd.availableKernelModules = ["xhci_pci" "virtio_pci" "uhci_hcd" "ehci_pci" "ahci" "usbhid" "sr_mod" "virtio_blk"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
  boot.resumeDevice = "/dev/disk/by-partlabel/swap\\x20partition";
  boot.zfs.forceImportRoot = false; # Disable backwards compatibility options
  boot.zfs.allowHibernation = true; # Make sure not use Swap on ZFS
  boot.zfs.devNodes = "/dev/disk/by-partlabel"; # For virtio-blk, there is no disks in /dev/disk/by-id

  swapDevices = [{device = "/dev/disk/by-partlabel/swap\\x20partition";}];

  # Disable zfs-mount, use NixOS systemd mount management
  # Ref: https://wiki.nixos.org/wiki/ZFS#ZFS_conflicting_with_systemd
  systemd.services.zfs-mount.enable = false;

  fileSystems = {
    "/" = {device = "zroot/default"; fsType = "zfs"; options = ["zfsutil"];};
    "/home" = {device = "zroot/home"; fsType = "zfs"; options = ["zfsutil"];};
    "/nix" = {device = "zroot/nix"; fsType = "zfs"; options = ["zfsutil"];};
    "/root" = {device = "zroot/home/root"; fsType = "zfs"; options = ["zfsutil"];};
    "/boot" = {
      device = "/dev/disk/by-partlabel/EFI\\x20system\\x20partition";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = true;
  networking.hostId = "14cb080c"; # ZFS requires this

  nixpkgs.hostPlatform = "x86_64-linux";
}
