{config, pkgs, lib, ...}: let
  shell_aliases = {
    k = "kubectl";
    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    ls = "ls --color=auto -v";
    ll = "ls -l --color=auto -v";
    la = "ls -la --color=auto -v";
    lh = "ls -lah --color=auto -v";
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
in {
  home.sessionVariables = { # environment variables that always set at login
    LESS = "-R -N";
    LESSHISTFILE = config.xdg.cacheHome + "/less/history";
    LESSKEY = config.xdg.configHome + "/less/lesskey";
    WINEPREFIX = config.xdg.dataHome + "/wine";

    # set default applications
    BROWSER = "firefox";

    # enable scrolling in git diff
    DELTA_PAGER = "less -R";
  };

  home.shellAliases = shell_aliases;

  programs.zsh.enable = true;

  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    shellAliases = lib.mkForce (builtins.removeAttrs shell_aliases [
      "ls" "ll" "lh" "la" "man" "ssh" "cpr" "mvr" "diff"
    ]);
    # load the alias file for work
    # the file must exist, otherwise nushell will complain about it!
    #
    # currently, nushell does not support conditional sourcing of files
    # https://github.com/nushell/nushell/issues/8214
    extraConfig = with pkgs; ''
      # completion
      use ${nu_scripts}/share/nu_scripts/custom-completions/git/git-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/glow/glow-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/just/just-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/make/make-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/man/man-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/nix/nix-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/cargo/cargo-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/zellij/zellij-completions.nu *
      # alias
      # use ${nu_scripts}/share/nu_scripts/aliases/git/git-aliases.nu *
      use ${nu_scripts}/share/nu_scripts/aliases/eza/eza-aliases.nu *
      use ${nu_scripts}/share/nu_scripts/aliases/bat/bat-aliases.nu *
    '';
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:${local_bin}:${go_bin}:${rust_bin}"
    '';
  };
}
