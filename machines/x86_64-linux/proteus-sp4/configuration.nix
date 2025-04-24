_: {
  modules.desktop.wayland.enable = true;
  modules.secrets.desktop.enable = true;
  networking.wireless.iwd.enable = true;
  # conflict with feature: containerd-snapshotter
  # virtualisation.docker.storageDriver = "btrfs";
}
