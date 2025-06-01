{lib, ...}: let
  shellAliases = {"zj" = "zellij";};
in with lib; {
  programs.zellij.enable = mkDefault true;
  home.shellAliases = shellAliases;
  xdg.configFile."zellij/config.kdl".source = mkDefault ./zellij.kdl;
}
