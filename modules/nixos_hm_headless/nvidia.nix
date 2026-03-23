{config, lib, ...}: let
  cfg = config.wayland.windowManager.hyprland;
in {
  options.wayland.windowManager.hyprland = {
    nvidia = lib.mkEnableOption "Whether nvidia GPU is used exclusively";
  };
  # Ref: https://wiki.hyprland.org/Nvidia/
  config = lib.mkIf cfg.nvidia {
    home.sessionVariables = {
      # https://web.archive.org/web/20260309182128/https://wiki.hypr.land/Configuring/Multi-GPU/#telling-hyprland-which-gpu-to-use
      LIBVA_DRIVER_NAME = "nvidia"; # Verify: `vainfo`
      # GBM_BACKEND = "nvidia-drm";
      # Verify: `glxinfo | grep -i "vendor string"`
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };
    # PRIME Sync mode for Hyprland
    wayland.windowManager.hyprland.settings.env = [
      "AQ_DRM_DEVICES,/dev/dri/card1:/dev/dri/card2"
    ];
  };
}
