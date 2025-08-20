{config, modulesPath, ...}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "uas" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];
  boot.kernelParams = [
    "i915.enable_guc=2"
    "i915.mitigations=off"
    "mitigations=off"
    "bgrt_disable"
    # "quiet"
  ];
  boot.resumeDevice = "/dev/mapper/swap";
  boot.zfs.forceImportRoot = false;
  boot.zfs.allowHibernation = true; # Make sure not use Swap on ZFS

  boot.initrd.luks.devices = {
    zroot1.device = "/dev/disk/by-id/nvme-eui.002538b121b3218a-part3";
    zroot2.device = "/dev/disk/by-id/nvme-eui.0025388981b0cba6-part1";
  };

  swapDevices = [{
    device = "/dev/mapper/swap";
    encrypted.enable = true;
    encrypted.label = "swap";
    encrypted.blkDev = "/dev/disk/by-id/nvme-eui.002538b121b3218a-part2";
  }];
  # Disable zfs-mount, use NixOS systemd mount management
  # Ref: https://wiki.nixos.org/wiki/ZFS#ZFS_conflicting_with_systemd
  systemd.services.zfs-mount.enable = false;
  fileSystems = { # The zfsutil option is needed when mounting zfs datasets without `legacy` mountpoints
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
  networking.hostId = "5736070c"; # ZFS requires this

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
}
