{myvars, mylib, lib, pkgs, config, ...}: let
  shell_aliases = {
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
in with lib; {
  home.stateVersion = mkDefault myvars.state_version;
  programs.home-manager.enable = mkDefault true;
  imports = mylib.scan_path ./.;
  home.packages = with pkgs; [
    fastfetch
    tlrc
    (ripgrep.override {withPCRE2 = true;})
    just

    ## Nix Related
    # It provides the command `nom` works just like `nix
    # with more details log output
    nix-output-monitor
    hydra-check # check hydra(nix's build farm) for the build status of a package
    nix-index # A small utility to index nix store paths
    nix-init # generate nix derivation from url
    # https://github.com/nix-community/nix-melt
    nix-melt # A TUI flake.lock viewer
    # https://github.com/utdemir/nix-tree
    nix-tree # A TUI to visualize the dependency graph of a nix derivation

    anki-bin
    blender # 3D creation suite
    firefox
    google-chrome
    moonlight # Remote desktop client
    winetricks

    vscode
    joplin-desktop # Note taking app, https://joplinapp.org/help/
    code-cursor # An AI code editor
    utm # Virtual machine manager for Apple platforms
    insomnia # REST client
    wireshark # Network analyzer
  ];
  xdg.enable = mkDefault true; # enable management of XDG base directories on macOS
  home.shellAliases = shell_aliases;
  services.syncthing.enable = mkDefault true;
  programs = {
    zsh = {
      enable = mkDefault true;
      autosuggestion = {
        enable = mkDefault true;
        highlight = mkDefault "fg=60";
        strategy = mkDefault ["match_prev_cmd" "history" "completion"];
      };
    };
    starship = {
      enable = mkDefault true;
      settings = {
        add_newline = mkDefault false;
        line_break.disabled = mkDefault true;
        status.disabled = mkDefault false;
        character.success_symbol = mkDefault "[➜ ](bold green)";
        character.error_symbol = mkDefault "[✗ ](bold red)";
        aws.disabled = mkDefault true;
        aws.symbol = mkDefault "🅰 ";
        gcloud = {
          disabled = mkDefault true;
          # do not show the account/project's info
          # to avoid the leak of sensitive information when sharing the terminal
          format = mkDefault "on [$symbol$active(\($region\))]($style) ";
          symbol = mkDefault "🅶 ️";
        };
        hostname.ssh_only = mkDefault false;
        hostname.format = mkDefault "[$ssh_symbol$hostname]($style) ";
        time.disabled = mkDefault false;
        time.format = mkDefault "[$time]($style)";
        right_format = mkDefault "[$status$time]($style)";
        username.format = mkDefault "[$user]($style) @ ";
        username.show_always = mkDefault true;
        palette = mkDefault "catppuccin_mocha";
      }
      // builtins.fromTOML (builtins.readFile "${myvars.catppuccin}/starship/${myvars.catppuccin_variant}.toml");
    };
    eza = { # A modern replacement for ‘ls’, useful in bash/zsh prompt, but not in nushell
      enable = mkDefault true;
      enableNushellIntegration = mkDefault false; # do not enable aliases in nushell!
      git = mkDefault true;
      icons = mkDefault "auto";
    };
    fzf = { # A command-line fuzzy finder.Interactively filter its input using fuzzy searching, not limit to filenames.
      enable = mkDefault true;
      defaultOptions = ["-m"];
      defaultCommand = mkDefault "rg --files"; # Using ripgrep in fzf
      # https://github.com/catppuccin/fzf
      # catppuccin-mocha
      colors = {
        "bg+" = mkDefault "#313244";
        "bg" = mkDefault "#1e1e2e";
        "spinner" = mkDefault "#f5e0dc";
        "hl" = mkDefault "#f38ba8";
        "fg" = mkDefault "#cdd6f4";
        "header" = mkDefault "#f38ba8";
        "info" = mkDefault "#cba6f7";
        "pointer" = mkDefault "#f5e0dc";
        "marker" = mkDefault "#f5e0dc";
        "fg+" = mkDefault "#cdd6f4";
        "prompt" = mkDefault "#cba6f7";
        "hl+" = mkDefault "#f38ba8";
      };
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
    zoxide.enable = mkDefault true;
    # Atuin replaces your existing shell history with a SQLite database,
    # and records additional context for your commands.
    # Additionally, it provides optional and fully encrypted
    # synchronisation of your history between machines, via an Atuin server.
    atuin.enable = mkDefault true;
    atuin.settings.sync_address = mkDefault "https://proteusdesktop.tailba6c3f.ts.net:8888";
    ## START helix.nix
    helix = {
      enable = mkDefault true;
      defaultEditor = mkDefault true;
      extraPackages = with pkgs; [nil marksman ltex-ls texlab nodePackages.vscode-json-languageserver];
      settings = {
        theme = mkDefault "gruvbox";
        editor = {
          bufferline = mkDefault "multiple";
          color-modes = mkDefault true;
          cursorline = mkDefault true;
          line-number = mkDefault "relative";
          rulers = mkDefault [80 120];
          true-color = mkDefault true;
          soft-wrap.enable = mkDefault true;
          cursor-shape.insert = mkDefault "bar";
          file-picker.hidden = mkDefault false;
          indent-guides.render = mkDefault true;
          statusline = {
            left = mkDefault ["mode" "spinner" "file-name" "read-only-indicator" "file-modification-indicator"];
            right = mkDefault ["diagnostics" "version-control" "selections" "position" "file-encoding" "file-line-ending" "file-type"];
          };
          whitespace.render = {
            space = mkDefault "all";
            tab = mkDefault "all";
            nbsp = mkDefault "all";
            nnbsp = mkDefault "all";
            newline = mkDefault "none";
          };
        };
        keys = mkDefault {
          insert."C-c" = "normal_mode";
          normal."F5" = [":config-reload" ":lsp-restart"];
        };
      };
      languages = {
        language = [{
          name = "cpp";
          auto-format = mkDefault true;
        }{
          name = "markdown";
          language-servers = mkDefault ["marksman" "ltex"];
        }{
          name = "latex";
          language-servers = mkDefault ["texlab" "ltex"];
        }];
        language-server = {
          ltex = {
            command = mkDefault "ltex-ls";
            config.ltex = {
              language = mkDefault "en-US";
              dictionary = { "en-US" = ["Gamescope" "MangoHud" "keyring"]; }; # TODO separate
            };
          };
          texlab.config.texlab = {
            chktex = {
              onOpenAndSave = mkDefault true;
              onEdit = mkDefault true;
            };
            forwardSearch = {
              executable = mkDefault "zathura";
              args = mkDefault ["--synctex-forward" "%l:1:%f" "%p"];
            };
            build = {
              executable = mkDefault "latexmk";
              args = mkDefault ["-cd" "-pdflua" "-halt-on-error" "-interaction=nonstopmode" "-synctex=1" "%f"];
              onSave = mkDefault true;
              forwardSearchAfter = mkDefault true;
            };
          };
        };
      };
    };
    ## END helix.nix
    yazi = { # terminal file manager
      enable = mkDefault true;
      # Changing working directory when exiting Yazi
      settings = {
        manager = {
          show_hidden = mkDefault true;
          sort_dir_first = mkDefault true;
        };
      };
    };
    # xdg.configFile."yazi/theme.toml".source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-yazi}/mocha.toml";
  };
  ## START btop.nix
  xdg.configFile."btop/themes".source = "${myvars.catppuccin}/btop/"; # https://github.com/catppuccin/btop/blob/main/themes/catppuccin_mocha.theme
  programs.btop = { # Alternative to htop/nmon
    enable = mkDefault true;
    settings = {
      color_theme = mkDefault "catppuccin_${myvars.catppuccin_variant}";
      theme_background = mkDefault false; # Make btop transparent
    };
  };
  ## END btop.nix
 ## START gpg.nix
  programs.gpg = {
    enable = mkDefault true;
    # $GNUPGHOME/trustdb.gpg stores all the trust level you specified in `programs.gpg.publicKeys` option. If set `mutableTrust` to false, the path $GNUPGHOME/trustdb.gpg will be overwritten on each activation. Thus we can only update trsutedb.gpg via home-manager.
    mutableTrust = mkDefault false;
    # $GNUPGHOME/pubring.kbx stores all the public keys you specified in `programs.gpg.publicKeys` option. If set `mutableKeys` to false, the path $GNUPGHOME/pubring.kbx will become an immutable link to the Nix store, denying modifications. Thus we can only update pubring.kbx via home-manager
    mutableKeys = mkDefault false;
    settings = { # This configuration is based on the tutorial https://blog.eleven-labs.com/en/openpgp-almost-perfect-key-pair-part-1, it allows for a robust setup
      no-greeting = mkDefault true; # Get rid of the copyright notice
      no-emit-version = mkDefault true; # Disable inclusion of the version string in ASCII armored output
      no-comments = mkOverride 999 false; # Do not write comment packets
      export-options = mkDefault "export-minimal"; # Export the smallest key possible. This removes all signatures except the most recent self-signature on each user ID
      keyid-format = mkDefault "0xlong"; # Display long key IDs
      with-fingerprint = mkDefault true; # List all keys (or the specified ones) along with their fingerprints
      list-options = mkDefault "show-uid-validity"; # Display the calculated validity of user IDs during key listings
      verify-options = mkOverride 999 "show-uid-validity show-keyserver-urls";
      personal-cipher-preferences = mkOverride 999 "AES256"; # Select the strongest cipher
      personal-digest-preferences = mkOverride 999 "SHA512"; # Select the strongest digest
      default-preference-list = mkOverride 999 "SHA512 SHA384 SHA256 RIPEMD160 AES256 TWOFISH BLOWFISH ZLIB BZIP2 ZIP Uncompressed"; # This preference list is used for new keys and becomes the default for "setpref" in the edit menu

      cipher-algo = mkDefault "AES256"; # Use the strongest cipher algorithm
      digest-algo = mkDefault "SHA512"; # Use the strongest digest algorithm
      cert-digest-algo = mkDefault "SHA512"; # Message digest algorithm used when signing a key
      compress-algo = mkDefault "ZLIB"; # Use RFC-1950 ZLIB compression

      disable-cipher-algo = mkDefault "3DES"; # Disable weak algorithm
      weak-digest = mkDefault "SHA1"; # Treat the specified digest algorithm as weak

      s2k-cipher-algo = mkDefault "AES256"; # The cipher algorithm for symmetric encryption for symmetric encryption with a passphrase
      s2k-digest-algo = mkDefault "SHA512"; # The digest algorithm used to mangle the passphrases for symmetric encryption
      s2k-mode = mkDefault "3"; # Selects how passphrases for symmetric encryption are mangled
      s2k-count = mkDefault "65011712"; # Specify how many times the passphrases mangling for symmetric encryption is repeated
    };
  };
  # I cannot bootout the 'system/com.openssh.ssh-agent', as it seizes the '$SSH_AUTH_SOCK'
  home.sessionVariablesExtra = ''
    export SSH_AUTH_SOCK="$(${config.programs.gpg.package}/bin/gpgconf --list-dirs agent-ssh-socket)"
  '';
  services.gpg-agent = { # gpg agent with pinentry-qt
    enable = mkDefault true;
    pinentry.package = mkDefault pkgs.pinentry-curses;
    enableSshSupport = mkDefault true;
    defaultCacheTtl = mkDefault (4 * 60 * 60); # 4 hours
    sshKeys = mkDefault myvars.gpg2ssh_keygrip; # Run 'gpg --export-ssh-key gpg-key!' to export public key
  };
  # launchd.agents.gpg-agent.config = { # enable logs for debugging
  #   StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/gnupg-agent.stderr.log";
  #   StandardOutPath = "${config.home.homeDirectory}/Library/Logs/gnupg-agent.stdout.log";
  # };
  ## END gpg.nix
  ## ghostty.nix
  programs.ghostty = { # terminal emulator
    enable = mkDefault true;
    package = mkDefault pkgs.ghostty-bin; # As of Jun 1, 2025, it's still marked as broken on MacOS, use pkgs.emptyFile (or pkgs.emptyDirectory or null if formers don't work) as a dummy package
    settings = { # https://ghostty.org/docs/config/reference
      macos-option-as-alt = mkDefault "left";
      keybind = [
        "alt+left=unbind"
        "alt+right=unbind"
      ];
      font-family = mkDefault "Iosevka Nerd Font Mono";
      font-size = mkDefault 13;
      background-opacity = mkDefault 0.93;
      background-blur = mkDefault true;
      scrollback-limit = mkDefault 20000;
    };
  };
  ## END ghostty.nix
}
