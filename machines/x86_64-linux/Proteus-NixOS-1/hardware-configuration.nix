{config, lib, pkgs, modulesPath, ...}: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a4fb86f7-6719-4263-ab8f-648b4fa57ce7";
    fsType = "ext4";
    options = ["discard"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D24A-7810";
    fsType = "vfat";
    options = ["discard" "fmask=0022" "dmask=0022"];
  };

  swapDevices = [];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = true;
  # networking.interfaces.ens3.useDHCP = true;

  nixpkgs.hostPlatform = "x86_64-linux";
}
