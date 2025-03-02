_: {
  modules.desktop.wayland.enable = true;
  # modules.secrets.desktop.enable = true;
  # modules.secrets.impermanence.enable = true;
  # conflict with feature: containerd-snapshotter
  # virtualisation.docker.storageDriver = "btrfs";
}
