{lib, config, pkgs, ...}: {
  home.sessionVariables = { # Environment variables that always set at login
    LESS = lib.mkDefault "-R -N";
    LESSHISTFILE = lib.mkDefault (config.xdg.cacheHome + "/less/history");
    LESSKEY = lib.mkDefault (config.xdg.configHome + "/less/lesskey");
    WINEPREFIX = lib.mkDefault (config.xdg.dataHome + "/wine");
    DELTA_PAGER = lib.mkDefault "less -R"; # Enable scrolling in git diff
  };
  home.shellAliases = {
    k = "kubectl";
    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    grep = "grep --color=auto";
    # ip = "ip --color=auto"; # `iproute2mac` doesn't support color, as of 7/22/2025
    cp = "cp -i";
    bc = "bc -lq";
    cpr = "rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 \"$@\"";
    mvr = "rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 --remove-source-files \"$@\"";
    diff = "command diff --text --unified --new-file --color=auto \"$@\"";
    man = "MANPAGER=\"less -R --use-color -Dd+r -Du+b\"" # Set boldface -> red color, underline -> blue color
      + " MANROFFOPT=\"-P-c\""
      + " command man \"$@\"";
  };
  programs.zsh = {
    enable = lib.mkDefault true;
    package = pkgs.emptyDirectory;
    autosuggestion = {
      enable = lib.mkDefault true;
      highlight = lib.mkDefault "fg=60";
      strategy = lib.mkDefault ["match_prev_cmd" "history" "completion"];
    };
  };
}
