{pkgs, config, lib, mylib, ...}@args: with lib; let
  cfg = config.modules.desktop.hyprland;
in {
  options.modules.desktop.hyprland = {
    enable = mkEnableOption "Hyprland compositor";
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
      default = mkDefault {};
    };
    nvidia = mkEnableOption "Whether nvidia GPU is used exclusively";
  };
  config = mkIf cfg.enable (mkMerge ( # Merge multiple sets of option definitions together
    [
      {wayland.windowManager.hyprland.settings = cfg.settings;}
      (mkIf cfg.nvidia { # For Hyprland with Nvidia gpu, ref
      # https://wiki.hyprland.org/Nvidia/
        wayland.windowManager.hyprland.settings.env = [ 
          "LIBVA_DRIVER_NAME,nvidia"
          "GBM_BACKEND,nvidia-drm"
          "AQ_DRM_DEVICES,/dev/dri/card1"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
          "WLR_NO_HARDWARE_CURSORS,1" # fix https://github.com/hyprwm/Hyprland/issues/1520
        ];
      })
    ]
    ++ (map (i: import i args) (mylib.scan_path ./.))
  ));
}
