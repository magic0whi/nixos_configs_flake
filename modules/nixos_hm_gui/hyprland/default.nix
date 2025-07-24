{pkgs, config, lib, mylib, ...}@args: let
  cfg = config.modules.gui.hyprland;
in {
  options.modules.gui.hyprland = {
    enable = lib.mkEnableOption "Hyprland compositor";
    settings = lib.mkOption {
      type = with lib.types; let
        valueType = nullOr (oneOf [
          bool
          int
          float
          str
          path
          (attrsOf valueType)
          (listOf valueType)
        ]) // {description = "Hyprland configuration value";};
      in valueType;
      default = {};
    };
    nvidia = lib.mkEnableOption "Whether nvidia GPU is used exclusively";
  };
  config = lib.mkIf cfg.enable (lib.mkMerge ( # Merge multiple sets of option definitions together
    [
      {wayland.windowManager.hyprland.settings = cfg.settings;}
      (lib.mkIf cfg.nvidia { # For Hyprland with Nvidia gpu, ref https://wiki.hyprland.org/Nvidia/
        home.sessionVariables = {
          LIBVA_DRIVER_NAME = "nvidia";
          GBM_BACKEND = "nvidia-drm";
          AQ_DRM_DEVICES = "/dev/dri/card1";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          WLR_NO_HARDWARE_CURSORS = 1; # fix https://github.com/hyprwm/Hyprland/issues/1520
        };
      })
    ]
    ++ (map (i: import i args) (mylib.scan_path ./.))
  ));
}
