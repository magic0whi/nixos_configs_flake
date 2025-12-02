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
      device = "/dev/disk/by-uuid/AE3C-806E";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };
  };

  swapDevices = [{device = "/swapfile";}];

  nixpkgs.hostPlatform = "x86_64-linux";
}
