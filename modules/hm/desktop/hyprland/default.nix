{pkgs, config, lib, mylib, ...}@args:
with lib; let
  cfg = config.modules.desktop.hyprland;
in {
  imports = [
    # anyrun.homeManagerModules.default
    ./options
  ];
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
      default = {};
    };
  };
  config = mkIf cfg.enable (
    mkMerge (
      [{wayland.windowManager.hyprland.settings = cfg.settings;}]
      ++ (map (i: import i args) (mylib.scan_path ./values))
    )
  );
}
