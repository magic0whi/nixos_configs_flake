{modulesPath, ...}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" ];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems = {
    "/" = {
      device = "/dev/mapper/ocivolume-root";
      fsType = "xfs";};
    "/boot" = {
      device = "/dev/disk/by-uuid/8EB3-7302";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };
    "/boot/EFI" = {
      device = "/dev/disk/by-uuid/dd88872e-0527-4193-8282-b8281f1ae6fd";
      fsType = "xfs";
    };
  };

  swapDevices = [{device = "/swapfile";}];

  nixpkgs.hostPlatform = "x86_64-linux";
}
