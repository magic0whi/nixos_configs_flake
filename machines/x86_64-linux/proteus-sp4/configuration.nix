{pkgs, ...}: {
  modules.desktop.wayland.enable = true;
  modules.secrets.desktop.enable = true;
  networking.wireless.iwd.enable = true;
  # virtualisation.docker.storageDriver = "btrfs"; # conflict with feature: containerd-snapshotter
  hardware.graphics.extraPackages = with pkgs; [intel-media-driver intel-compute-runtime-legacy1];
}
