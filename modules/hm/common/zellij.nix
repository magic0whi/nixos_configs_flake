let
  shellAliases = {
    "zj" = "zellij";
  };
in {
  # programs.zellij.enable = true;
  home.shellAliases = shellAliases; # only works in bash/zsh, not nushell
  programs.nushell.shellAliases = shellAliases;
  xdg.configFile."zellij/config.kdl".source = ./zellij.kdl;
  # auto start zellij in nushell TODO
  # programs.nushell.extraConfig = ''
  #   # auto start zellij
  #   # except when in emacs or zellij itself
  #   if (not ("ZELLIJ" in $env)) and (not ("INSIDE_EMACS" in $env)) {
  #     if "ZELLIJ_AUTO_ATTACH" in $env and $env.ZELLIJ_AUTO_ATTACH == "true" {
  #       ^zellij attach -c
  #     } else {
  #       ^zellij
  #     }

  #     # Auto exit the shell session when zellij exit
  #     $env.ZELLIJ_AUTO_EXIT = "false" # disable auto exit
  #     if "ZELLIJ_AUTO_EXIT" in $env and $env.ZELLIJ_AUTO_EXIT == "true" {
  #       exit
  #     }
  #   }
  # '';
}
