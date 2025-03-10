{myvars, mylib, pkgs, nur-ryan4yin, config, ...}: {
  imports = mylib.scan_path ./commons;
  home = { # Home Manager needs a bit of information about you and the paths it should manage.
    inherit (myvars) username;
    homeDirectory = "/home/${myvars.username}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "25.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    # Misc
    tldr
    cowsay
    gnupg
    gnumake

    # Modern cli tools, replacement of grep/sed/...

    # Interactively filter its input using fuzzy searching, not limit to filenames.
    fzf
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

  programs = {
    # A modern replacement for ‘ls’
    # useful in bash/zsh prompt, not in nushell.
    eza = {
      enable = true;
      # do not enable aliases in nushell!
      enableNushellIntegration = false;
      git = true;
      icons = "auto";
    };

    # a cat(1) clone with syntax highlighting and Git integration.
    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "catppuccin-mocha";
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
    fzf = {
      enable = true;
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
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };

    # Atuin replaces your existing shell history with a SQLite database,
    # and records additional context for your commands.
    # Additionally, it provides optional and fully encrypted
    # synchronisation of your history between machines, via an Atuin server.
    atuin = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
  };
  ## START yazi.nix
  programs.yazi = { # terminal file manager
    enable = true;
    # Changing working directory when exiting Yazi
    enableBashIntegration = true;
    enableNushellIntegration = true;
    settings = {
      manager = {
        show_hidden = true;
        sort_dir_first = true;
      };
    };
  };

  xdg.configFile."yazi/theme.toml".source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-yazi}/mocha.toml";
  ## END yazi.nix
  ## START starship.nix
  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;

    settings =
      {
        character = {
          success_symbol = "[›](bold green)";
          error_symbol = "[›](bold red)";
        };
        aws = {
          symbol = "🅰 ";
        };
        gcloud = {
          # do not show the account/project's info
          # to avoid the leak of sensitive information when sharing the terminal
          format = "on [$symbol$active(\($region\))]($style) ";
          symbol = "🅶 ️";
        };

        palette = "catppuccin_mocha";
      }
      // builtins.fromTOML (builtins.readFile "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-starship}/palettes/mocha.toml");
  };
  ## END starship.nix
  ## START helix.nix
  # https://github.com/catppuccin/helix
  xdg.configFile."helix/themes".source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-helix}/themes/default";
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        bufferline = "multiple";
        color-modes = true;
        cursorline = true;
        line-number = "relative";
        rulers = [80 120];
        true-color = true;
        soft-wrap.enable = true;
        cursor-shape.insert = "bar";
        file-picker.hidden = false;
        indent-guides.render = true;
        statusline = {
          left = ["mode" "spinner" "file-name" "read-only-indicator" "file-modification-indicator"];
          right = ["diagnostics" "version-control" "selections" "position" "file-encoding" "file-line-ending" "file-type"];
        };
        whitespace.render = {
          space = "all";
          tab = "all";
          nbsp = "all";
          newline = "none";
        };
      };
      keys = {
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
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
  };
  ## END neovim.nix
  ## START gpg.nix
  programs.gpg = {
    enable = true;
    homedir = "${config.home.homeDirectory}/.gnupg";
    #  $GNUPGHOME/trustdb.gpg stores all the trust level you specified in `programs.gpg.publicKeys` option.
    #
    # If set `mutableTrust` to false, the path $GNUPGHOME/trustdb.gpg will be overwritten on each activation.
    # Thus we can only update trsutedb.gpg via home-manager.
    mutableTrust = false;

    # $GNUPGHOME/pubring.kbx stores all the public keys you specified in `programs.gpg.publicKeys` option.
    #
    # If set `mutableKeys` to false, the path $GNUPGHOME/pubring.kbx will become an immutable link to the Nix store, denying modifications.
    # Thus we can only update pubring.kbx via home-manager
    mutableKeys = false;
    publicKeys = [
      # https://www.gnupg.org/gph/en/manual/x334.html
      # { TODO
        # source = "${mysecrets}/public/ryan4yin-gpg-keys-2014-01-27.pub";
        # trust = 5;
      # } # ultimate trust, my own keys.
    ];

    # This configuration is based on the tutorial below, it allows for a robust setup
    # https://blog.eleven-labs.com/en/openpgp-almost-perfect-key-pair-part-1
    # ~/.gnupg/gpg.conf
    settings = {
      # Get rid of the copyright notice
      no-greeting = true;

      # Disable inclusion of the version string in ASCII armored output
      no-emit-version = true;
      # Do not write comment packets
      no-comments = false;
      # Export the smallest key possible
      # This removes all signatures except the most recent self-signature on each user ID
      export-options = "export-minimal";

      # Display long key IDs
      keyid-format = "0xlong";
      # List all keys (or the specified ones) along with their fingerprints
      with-fingerprint = true;

      # Display the calculated validity of user IDs during key listings
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity show-keyserver-urls";

      # Select the strongest cipher
      personal-cipher-preferences = "AES256";
      # Select the strongest digest
      personal-digest-preferences = "SHA512";
      # This preference list is used for new keys and becomes the default for "setpref" in the edit menu
      default-preference-list = "SHA512 SHA384 SHA256 RIPEMD160 AES256 TWOFISH BLOWFISH ZLIB BZIP2 ZIP Uncompressed";

      # Use the strongest cipher algorithm
      cipher-algo = "AES256";
      # Use the strongest digest algorithm
      digest-algo = "SHA512";
      # Message digest algorithm used when signing a key
      cert-digest-algo = "SHA512";
      # Use RFC-1950 ZLIB compression
      compress-algo = "ZLIB";

      # Disable weak algorithm
      disable-cipher-algo = "3DES";
      # Treat the specified digest algorithm as weak
      weak-digest = "SHA1";

      # The cipher algorithm for symmetric encryption for symmetric encryption with a passphrase
      s2k-cipher-algo = "AES256";
      # The digest algorithm used to mangle the passphrases for symmetric encryption
      s2k-digest-algo = "SHA512";
      # Selects how passphrases for symmetric encryption are mangled
      s2k-mode = "3";
      # Specify how many times the passphrases mangling for symmetric encryption is repeated
      s2k-count = "65011712";
    };
  };
  ## END gpg.nix
  # auto mount usb drives
  services = {
    udiskie.enable = true;
    syncthing.enable = true;
  };
}
