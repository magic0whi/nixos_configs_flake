{lib, myvars, mylib, pkgs, nur-ryan4yin, config, ...}: {
  imports = mylib.scan_path ./.;
  home = { # Home Manager needs a bit of information about you and the paths it should manage.
    inherit (myvars) username;
    homeDirectory = lib.mkDefault "/home/${myvars.username}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = lib.mkDefault "25.05";
  };
  programs.home-manager.enable = true; # Let Home Manager install and manage itself.
  home.packages = with pkgs; [
    # Misc
    tldr
    cowsay
    gnupg
    gnumake

    # Modern cli tools, replacement of grep/sed/...

    # search for files by name, faster than find
    fd
    # search for files by its content, replacement of grep
    (ripgrep.override {withPCRE2 = true;})

    # A fast and polyglot tool for code searching, linting, rewriting at large scale
    # supported languages: only some mainstream languages currently(do not support nix/nginx/yaml/toml/...)
    ast-grep

    sad # CLI search and replace, just like sed, but with diff preview.
    yq-go # yaml processor https://github.com/mikefarah/yq
    just # a command runner like make, but simpler
    delta # A viewer for git and diff output
    lazygit # Git terminal UI.
    hyperfine # command-line benchmarking tool
    gping # ping, but with a graph(TUI)
    doggo # DNS client for humans
    duf # Disk Usage/Free Utility - a better 'df' alternative
    du-dust # A more intuitive version of `du` in rust
    gdu # disk usage analyzer(replacement of `du`)

    # nix related
    #
    # it provides the command `nom` works just like `nix
    # with more details log output
    nix-output-monitor
    hydra-check # check hydra(nix's build farm) for the build status of a package
    nix-index # A small utility to index nix store paths
    nix-init # generate nix derivation from url
    # https://github.com/nix-community/nix-melt
    nix-melt # A TUI flake.lock viewer
    # https://github.com/utdemir/nix-tree
    nix-tree # A TUI to visualize the dependency graph of a nix derivation

    # productivity
    caddy # A webserver with automatic HTTPS via Let's Encrypt(replacement of nginx)
    croc # File transfer between computers securely and easily
    ncdu # analyzer your disk usage Interactively, via TUI(replacement of `du`)

    libnotify # notify-send
    wireguard-tools # manage wireguard vpn manually, via wg-quick

    ventoy # create bootable usb
    virt-viewer # vnc connect to VM, used by kubevirt
  ];

  programs = { # A modern replacement for ‘ls’, useful in bash/zsh prompt, but not in nushell.
    eza = {
      enable = lib.mkDefault true;
      enableNushellIntegration = lib.mkDefault false; # do not enable aliases in nushell!
      git = lib.mkDefault true;
      icons = lib.mkDefault "auto";
    };
    bat = { # a cat(1)-like with syntax highlighting and Git integration.
      enable = lib.mkDefault true;
      config = {
        pager = lib.mkDefault "less -FR";
        theme = lib.mkDefault "catppuccin-mocha";
      };
      themes = {
        # https://raw.githubusercontent.com/catppuccin/bat/main/Catppuccin-mocha.tmTheme
        catppuccin-mocha = {
          src = nur-ryan4yin.packages.${pkgs.system}.catppuccin-bat;
          file = "Catppuccin-mocha.tmTheme";
        };
      };
    };

    # A command-line fuzzy finder
    fzf = { # Interactively filter its input using fuzzy searching, not limit to filenames.
      enable = lib.mkDefault true;
      defaultOptions = ["-m"];
      defaultCommand = lib.mkDefault "rg --files"; # Using ripgrep in fzf
      # https://github.com/catppuccin/fzf
      # catppuccin-mocha
      colors = {
        "bg+" = "#313244";
        "bg" = "#1e1e2e";
        "spinner" = "#f5e0dc";
        "hl" = "#f38ba8";
        "fg" = "#cdd6f4";
        "header" = "#f38ba8";
        "info" = "#cba6f7";
        "pointer" = "#f5e0dc";
        "marker" = "#f5e0dc";
        "fg+" = "#cdd6f4";
        "prompt" = "#cba6f7";
        "hl+" = "#f38ba8";
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
    zoxide.enable = lib.mkDefault true;

    # Atuin replaces your existing shell history with a SQLite database,
    # and records additional context for your commands.
    # Additionally, it provides optional and fully encrypted
    # synchronisation of your history between machines, via an Atuin server.
    atuin.enable = lib.mkDefault true;

    # tmux = { # I use zellij instead
    #   enable = true;
    #   keyMode = "vi";
    #   customPaneNavigationAndResize = true;
    #   shortcut = "a";
    # };
  };
  ## START yazi.nix
  programs.yazi = { # terminal file manager
    enable = lib.mkDefault true;
    # Changing working directory when exiting Yazi
    settings = {
      manager = {
        show_hidden = lib.mkDefault true;
        sort_dir_first = lib.mkDefault true;
      };
    };
  };
  xdg.configFile."yazi/theme.toml".source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-yazi}/mocha.toml";
  ## END yazi.nix
  ## START starship.nix
  programs.starship = {
    enable = lib.mkDefault true;
    settings = {
      add_newline = lib.mkDefault false;
      line_break.disabled = lib.mkDefault true;
      status.disabled = lib.mkDefault false;
      character.success_symbol = lib.mkDefault "[➜ ](bold green)";
      character.error_symbol = lib.mkDefault "[✗ ](bold red)";
      aws.disabled = lib.mkDefault true;
      aws.symbol = lib.mkDefault "🅰 ";
      gcloud = {
        disabled = lib.mkDefault true;
        # do not show the account/project's info
        # to avoid the leak of sensitive information when sharing the terminal
        format = lib.mkDefault "on [$symbol$active(\($region\))]($style) ";
        symbol = lib.mkDefault "🅶 ️";
      };
      hostname.ssh_only = lib.mkDefault false;
      hostname.format = lib.mkDefault "[$ssh_symbol$hostname]($style) ";
      time.disabled = lib.mkDefault false;
      time.format = lib.mkDefault "[$time]($style)";
      right_format = lib.mkDefault "[$status$time]($style)";
      username.format = lib.mkDefault "[$user]($style) @ ";
      username.show_always = lib.mkDefault true;
      palette = lib.mkDefault "catppuccin_mocha";
    }
    // builtins.fromTOML (builtins.readFile "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-starship}/palettes/mocha.toml");
  };
  ## END starship.nix
  ## START helix.nix
  # https://github.com/catppuccin/helix
  xdg.configFile."helix/themes".source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-helix}/themes/default";
  programs.helix = {
    enable = lib.mkDefault true;
    defaultEditor = lib.mkDefault true;
    extraPackages = with pkgs; [marksman ltex-ls texlab];
    settings = {
      theme = lib.mkDefault "catppuccin_mocha";
      editor = {
        bufferline = lib.mkDefault "multiple";
        color-modes = lib.mkDefault true;
        cursorline = lib.mkDefault true;
        line-number = lib.mkDefault "relative";
        rulers = lib.mkDefault [80 120];
        true-color = lib.mkDefault true;
        soft-wrap.enable = lib.mkDefault true;
        cursor-shape.insert = lib.mkDefault "bar";
        file-picker.hidden = lib.mkDefault false;
        indent-guides.render = lib.mkDefault true;
        statusline = {
          left = lib.mkDefault ["mode" "spinner" "file-name" "read-only-indicator" "file-modification-indicator"];
          right = lib.mkDefault ["diagnostics" "version-control" "selections" "position" "file-encoding" "file-line-ending" "file-type"];
        };
        whitespace.render = {
          space = lib.mkDefault "all";
          tab = lib.mkDefault "all";
          nbsp = lib.mkDefault "all";
          newline = lib.mkDefault "none";
        };
      };
      keys = lib.mkDefault {
        insert."C-c" = "normal_mode";
        normal."F5" = [":config-reload" ":lsp-restart"];
      };
    };
    languages = {
      language = [{
        name = "cpp";
        auto-format = true;
      }{
        name = "markdown";
        language-servers = ["marksman" "ltex"];
      }{
        name = "latex";
        language-servers = ["texlab" "ltex"];
      }];
      language-server = {
        ltex = {
          command = "ltex-ls";
          config.ltex = {
            language = "en-US";
            dictionary = { "en-US" = ["Gamescope" "MangoHud"]; };
          };
        };
        texlab.config.texlab = {
          chktex = {
            onOpenAndSave = true;
            onEdit = true;
          };
          forwardSearch = {
            executable = "zathura";
            args = ["--synctex-forward" "%l:1:%f" "%p"];
          };
          build = {
            executable = "latexmk";
            args = ["-cd" "-pdflua" "-halt-on-error" "-interaction=nonstopmode" "-synctex=1" "%f"];
            onSave = true;
            forwardSearchAfter = true;
          };
        };
      };
    };
  };
  ## END helix.nix
  ## START neovim.nix
  programs = {
    neovim = {
      enable = lib.mkDefault true;
      viAlias = lib.mkDefault true;
      vimAlias = lib.mkDefault true;
    };
  };
  ## END neovim.nix
  ## START gpg.nix
  programs.gpg = {
    enable = lib.mkDefault true;
    # $GNUPGHOME/trustdb.gpg stores all the trust level you specified in `programs.gpg.publicKeys` option. If set `mutableTrust` to false, the path $GNUPGHOME/trustdb.gpg will be overwritten on each activation. Thus we can only update trsutedb.gpg via home-manager.
    mutableTrust = lib.mkDefault false;

    # $GNUPGHOME/pubring.kbx stores all the public keys you specified in `programs.gpg.publicKeys` option. If set `mutableKeys` to false, the path $GNUPGHOME/pubring.kbx will become an immutable link to the Nix store, denying modifications.
    # Thus we can only update pubring.kbx via home-manager
    mutableKeys = lib.mkDefault false;
    settings = { # This configuration is based on the tutorial https://blog.eleven-labs.com/en/openpgp-almost-perfect-key-pair-part-1, it allows for a robust setup
      no-greeting = lib.mkDefault true; # Get rid of the copyright notice
      no-emit-version = lib.mkDefault true; # Disable inclusion of the version string in ASCII armored output
      no-comments = lib.mkOverride 999 false; # Do not write comment packets
      export-options = lib.mkDefault "export-minimal"; # Export the smallest key possible. This removes all signatures except the most recent self-signature on each user ID
      keyid-format = lib.mkDefault "0xlong"; # Display long key IDs
      with-fingerprint = lib.mkDefault true; # List all keys (or the specified ones) along with their fingerprints
      list-options = lib.mkDefault "show-uid-validity"; # Display the calculated validity of user IDs during key listings
      verify-options = lib.mkOverride 999 "show-uid-validity show-keyserver-urls";
      personal-cipher-preferences = lib.mkOverride 999 "AES256"; # Select the strongest cipher
      personal-digest-preferences = lib.mkOverride 999 "SHA512"; # Select the strongest digest
      default-preference-list = lib.mkOverride 999 "SHA512 SHA384 SHA256 RIPEMD160 AES256 TWOFISH BLOWFISH ZLIB BZIP2 ZIP Uncompressed"; # This preference list is used for new keys and becomes the default for "setpref" in the edit menu

      cipher-algo = lib.mkDefault "AES256"; # Use the strongest cipher algorithm
      digest-algo = lib.mkDefault "SHA512"; # Use the strongest digest algorithm
      cert-digest-algo = lib.mkDefault "SHA512"; # Message digest algorithm used when signing a key
      compress-algo = lib.mkDefault "ZLIB"; # Use RFC-1950 ZLIB compression

      disable-cipher-algo = lib.mkDefault "3DES"; # Disable weak algorithm
      weak-digest = lib.mkDefault "SHA1"; # Treat the specified digest algorithm as weak

      s2k-cipher-algo = lib.mkDefault "AES256"; # The cipher algorithm for symmetric encryption for symmetric encryption with a passphrase
      s2k-digest-algo = lib.mkDefault "SHA512"; # The digest algorithm used to mangle the passphrases for symmetric encryption
      s2k-mode = lib.mkDefault "3"; # Selects how passphrases for symmetric encryption are mangled
      s2k-count = lib.mkDefault "65011712"; # Specify how many times the passphrases mangling for symmetric encryption is repeated
    };
  };
  ## END gpg.nix
  systemd.user.services."${myvars.username}".environment.STNODEFAULTFOLDER = lib.mkDefault "true"; # Don't create default ~/Sync folder
  services = {
    udiskie.enable = lib.mkDefault true; # auto mount usb drives
    syncthing.enable = lib.mkDefault true;
    syncthing.tray.enable = lib.mkDefault true;
  };
}
