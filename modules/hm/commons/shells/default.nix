{config, pkgs, ...}: let
  shellAliases = {
    k = "kubectl";

    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  };

  localBin = "${config.home.homeDirectory}/.local/bin";
  goBin = "${config.home.homeDirectory}/go/bin";
  rustBin = "${config.home.homeDirectory}/.cargo/bin";
in {
  # environment variables that always set at login
  home.sessionVariables = {
    # clean up ~
    LESSHISTFILE = config.xdg.cacheHome + "/less/history";
    LESSKEY = config.xdg.configHome + "/less/lesskey";
    WINEPREFIX = config.xdg.dataHome + "/wine";

    # set default applications
    BROWSER = "firefox";

    # enable scrolling in git diff
    DELTA_PAGER = "less -R";
  };

  # only works in bash/zsh, not nushell
  home.shellAliases = shellAliases;

  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    inherit shellAliases;
    # load the alias file for work
    # the file must exist, otherwise nushell will complain about it!
    #
    # currently, nushell does not support conditional sourcing of files
    # https://github.com/nushell/nushell/issues/8214
    extraConfig = with pkgs; ''
      source /etc/agenix/alias-for-work.nushell
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
      export PATH="$PATH:${localBin}:${goBin}:${rustBin}"
    '';
  };
}
