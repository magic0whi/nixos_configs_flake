{modulesPath, ...}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/e5140861-b17f-43b9-8b3d-d42a36ebc9ee";
      fsType = "ext4";};
    "/boot" = {
      device = "/dev/disk/by-uuid/43A5-304A";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };
  };

  swapDevices = [{device = "/swapfile";}];

  nixpkgs.hostPlatform = "x86_64-linux";
}
