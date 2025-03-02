{pkgs, config, lib, ...}: let
  cfg = config.modules.desktop.wayland;
in {
  # TODO
  config = lib.mkIf cfg.enable {};
}
