_: {
  modules.desktop.wayland.enable = true;
  modules.secrets.desktop.enable = true;
  networking.wireless.iwd.enable = true;
  # virtualisation.docker.storageDriver = "btrfs"; # conflict with feature: containerd-snapshotter
}
