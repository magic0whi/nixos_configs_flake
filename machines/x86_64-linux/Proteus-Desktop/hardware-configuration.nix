{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "nvme" "usbhid" "uas" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];
  boot.zfs.forceImportRoot = false; # Disable backwards compatibility options
  boot.zfs.unsafeAllowHibernation = true; # Make sure not use Swap on ZFS

  # Disable zfs-mount, use NixOS systemd mount management
  # Ref: https://wiki.nixos.org/wiki/ZFS#ZFS_conflicting_with_systemd
  systemd.services.zfs-mount.enable = false;

  # disko will take care of filesystems.*, swapDevices, boot.resumeDevice, boot.initrd.luks.devices (not always work)

  boot.initrd.luks.devices = let
    satas = [
      "ata-ST500DM002-1BD142_S2A7EA2P"
      "ata-WDC_WD5000AAKX-001CA0_WD-WMAYU5316042"
      "ata-WDC_WD5000AAKX-60U6AA0_WD-WCC2E3HEXA48"
      "ata-ST1000DM003-1CH162_S1DE5CWF"
      "ata-ST1000LM048-2E7172_WKPEZYSN"
      "ata-WDC_WD2002FYPS-02W3B0_WCAVY6186321"
    ];
  in (lib.genAttrs satas (name: {
    device = "/dev/disk/by-id/${name}-part1";
    # fallbackToPassword = true;
    crypttabExtraOpts = ["nofail"];
    keyFile = "/persistent/etc/dm_keyfile.key"; # TODO: Unsafe
    keyFileTimeout = 15;
    allowDiscards = true;
    bypassWorkqueues = true;
  }));

  networking.useDHCP = true;
  networking.hostId = "953b2f69"; # ZFS requires this

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
}
