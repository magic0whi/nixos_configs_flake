{config, pkgs, lib, mylib, myvars, ...}: {
  home.packages = with pkgs; [
    tlrc # tldr written in Rust
    fd # search for files by name, faster than find
    (ripgrep.override {withPCRE2 = true;}) # search for files by its content, replacement of grep
  ];
  ## START zellij.nix
  programs.zellij.enable = true;
  home.shellAliases."zj" = "zellij";
  xdg.configFile."zellij/config.kdl".source = mylib.relative_to_root "custom_files/zellij.kdl";
  ## END zellij.nix

  home.sessionVariables = { # Environment variables that always set at login
    LESS = "-R -N";
    LESSHISTFILE = config.xdg.cacheHome + "/less/history";
    LESSKEY = config.xdg.configHome + "/less/lesskey";
    WINEPREFIX = config.xdg.dataHome + "/wine";
    DELTA_PAGER = "less -R"; # Enable scrolling in git diff
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
  programs = {
    zsh = {
      enable = true;
      package = pkgs.emptyDirectory;
      autosuggestion = {
        enable = true;
        highlight = "fg=60";
        strategy = ["match_prev_cmd" "history" "completion"];
      };
      initContent = let
        local_bin = "${config.home.homeDirectory}/.local/bin";
        go_bin = "${config.home.homeDirectory}/go/bin";
        rust_bin = "${config.home.homeDirectory}/.cargo/bin";
      in lib.mkAfter ''export PATH="$PATH:${local_bin}:${go_bin}:${rust_bin}"'';
    };
    eza = { # A modern replacement for ‘ls’, useful in bash/zsh prompt, but not in nushell
      enable = true;
      git = true;
      icons = "auto";
    };
    bat = { # a cat-like with syntax highlighting and Git integration.
      enable = true;
      config = {
        pager = "less -FR";
      };
    };
    # A command-line fuzzy finder. Interactively filter its input using fuzzy searching, not limit to filenames.
    fzf = {
      enable = true;
      defaultOptions = ["-m"];
      defaultCommand = "rg --files"; # Using ripgrep in fzf
    };
    # zoxide is a smarter cd command, inspired by z and autojump.
    # It remembers which directories you use most frequently,
    # so you can "jump" to them in just a few keystrokes.
    # zoxide works on all major shells.
    #
    #   z foo              # cd into highest ranked directory matching foo
    #   z foo bar          # cd into highest ranked directory matching foo and bar
    #   z foo /            # cd into a subdirectory starting with foo
    #
    #   z ~/foo            # z also works like a regular cd command
    #   z foo/             # cd into relative path
    #   z ..               # cd one level up
    #   z -                # cd into previous directory
    #
    #   zi foo             # cd with interactive selection (using fzf)
    #
    #   z foo<SPACE><TAB>  # show interactive completions (zoxide v0.8.0+, bash 4.4+/fish/zsh only)
    zoxide.enable = true;

    # Atuin replaces your existing shell history with a SQLite database,
    # and records additional context for your commands.
    # Additionally, it provides optional and fully encrypted
    # synchronisation of your history between machines, via an Atuin server.
    atuin.enable = true;
    atuin.settings.sync_address = "https://proteusdesktop.tailba6c3f.ts.net:8888";

    starship = {
      enable = true;
      settings = {
        add_newline = false;
        line_break.disabled = true;
        status.disabled = false;
        character.success_symbol = "[➜ ](bold green)";
        character.error_symbol = "[✗ ](bold red)";
        aws.disabled = true;
        aws.symbol = "🅰 ";
        gcloud = {
          disabled = true;
          # Do not show the account/project's info to avoid the leak of sensitive information when sharing the
          # terminal
          format = "on [$symbol$active(\($region\))]($style) ";
          symbol = "🅶 ️";
        };
        hostname.ssh_only = false;
        hostname.format = "[$ssh_symbol$hostname]($style) ";
        time.disabled = false;
        time.format = "[$time]($style)";
        right_format = "[$status$time]($style)";
        username.format = "[$user]($style) @ ";
        username.show_always = true;
      };
    };
    # tmux = {
    #   enable = true;
    #   keyMode = "vi";
    #   customPaneNavigationAndResize = true;
    #   shortcut = "a";
    # };
  };
}
