{config, pkgs, lib, ...}: let
  shell_aliases = {
    k = "kubectl";
    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    grep = "grep --color=auto";
    ip = "ip --color=auto";
    cp = "cp -i";
    ssh = "TERM=xterm-256color ssh";
    bc = "bc -lq";
    Ci = "wl-copy";
    Co = "wl-paste";
    Coimg = "Co --type image";
    cpr = "rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 \"$@\"";
    mvr = "rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 --remove-source-files \"$@\"";
    diff = "command diff --text --unified --new-file --color=auto \"$@\"";
    # Set boldface -> red color, underline -> blue color
    man = "MANPAGER=\"less -R --use-color -Dd+r -Du+b\""
      + " MANROFFOPT=\"-P-c\""
      + " command man \"$@\"";
  };
  local_bin = "${config.home.homeDirectory}/.local/bin";
  go_bin = "${config.home.homeDirectory}/go/bin";
  rust_bin = "${config.home.homeDirectory}/.cargo/bin";
in with lib; {
  home.sessionVariables = { # Environment variables that always set at login
    LESS = mkDefault "-R -N";
    LESSHISTFILE = mkDefault (config.xdg.cacheHome + "/less/history");
    LESSKEY = mkDefault (config.xdg.configHome + "/less/lesskey");
    WINEPREFIX = mkDefault (config.xdg.dataHome + "/wine");
    BROWSER = mkDefault "google-chrome-stable"; # Set default applications
    DELTA_PAGER = mkDefault "less -R"; # Enable scrolling in git diff
  };
  home.shellAliases = shell_aliases;
  programs.zsh.enable = mkDefault true;
  programs.bash = {
    enable = mkDefault true;
    enableCompletion = mkDefault true;
    bashrcExtra = ''
      export PATH="$PATH:${local_bin}:${go_bin}:${rust_bin}"
    '';
  };
}
