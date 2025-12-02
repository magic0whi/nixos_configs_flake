{config, lib, ...}: let
  cfg = config.wayland.windowManager.hyprland;
in {
  options.wayland.windowManager.hyprland = {
    nvidia = lib.mkEnableOption "Whether nvidia GPU is used exclusively";
  };
  config = lib.mkIf cfg.nvidia { # For Hyprland with Nvidia GPU, ref https://wiki.hyprland.org/Nvidia/
    home.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      AQ_DRM_DEVICES = "/dev/dri/card1";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = 1; # fix https://github.com/hyprwm/Hyprland/issues/1520
    };
  };
}
