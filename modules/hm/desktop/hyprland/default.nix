{pkgs, config, lib, mylib, ...}@args: with lib; let
  cfg = config.modules.desktop.hyprland;
in {
  imports = [./options];
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
  };
  config = mkIf cfg.enable (mkMerge ( # Merge multiple sets of option definitions together
    [{wayland.windowManager.hyprland.settings = cfg.settings;}]
    ++ (map (i: import i args) (mylib.scan_path ./values))
  ));
}
