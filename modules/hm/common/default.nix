{lib, myvars, mylib, pkgs, ...}: with lib; {
  imports = mylib.scan_path ./.;
  home = { # Home Manager needs a bit of information about you and the paths it should manage.
    inherit (myvars) username;
    homeDirectory = mkDefault "/home/${myvars.username}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = mkDefault myvars.state_version;
  };
  programs.home-manager.enable = true; # Let Home Manager install and manage itself.
  home.packages = with pkgs; [
    # Misc
    tlrc # tldr written in Rust
    cowsay
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

    # ventoy # create bootable usb
    virt-viewer # vnc connect to VM, used by kubevirt
  ];

  programs = { # A modern replacement for ‘ls’, useful in bash/zsh prompt, but not in nushell.
    eza = {
      enable = mkDefault true;
      enableNushellIntegration = mkDefault false; # do not enable aliases in nushell!
      git = mkDefault true;
      icons = lib.mkDefault "auto";
    };
    bat = { # a cat(1)-like with syntax highlighting and Git integration.
      enable = lib.mkDefault true;
      config = {
        pager = lib.mkDefault "less -FR";
        theme = lib.mkDefault "catppuccin-${myvars.catppuccin_variant}";
      };
      themes = {
        # https://raw.githubusercontent.com/catppuccin/bat/main/Catppuccin-mocha.tmTheme
        "catppuccin-${myvars.catppuccin_variant}" = {
          src = "${myvars.catppuccin}/bat";
          file = "Catppuccin ${myvars.catppuccin_variant}.tmTheme";
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
    atuin.enable = mkDefault true;
    atuin.settings.sync_address = mkDefault "https://proteusdesktop.tailba6c3f.ts.net:8888";

    # tmux = { # I use zellij instead
    #   enable = true;
    #   keyMode = "vi";
    #   customPaneNavigationAndResize = true;
    #   shortcut = "a";
    # };
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
  # xdg.configFile."yazi/theme.toml".source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-yazi}/mocha.toml";
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
    // builtins.fromTOML (builtins.readFile "${myvars.catppuccin}/starship/${myvars.catppuccin_variant}.toml");
  };
  ## END starship.nix
  ## START helix.nix
  # xdg.configFile."helix/themes".source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-helix}/themes/default"; # https://github.com/catppuccin/helix
  programs.helix = {
    enable = mkDefault true;
    defaultEditor = mkDefault true;
    extraPackages = with pkgs; [marksman ltex-ls texlab nodePackages.vscode-json-languageserver];
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
  programs.zathura = {
    enable = mkDefault true;
    options.selection-clipboard = mkDefault "clipboard";
  };
  ## END helix.nix
  ## START neovim.nix
  programs.neovim = {
    enable = mkDefault true;
    viAlias = mkDefault true;
    vimAlias = mkDefault true;
  };
  ## END neovim.nix
  ## START gpg.nix
  programs.gpg = {
    enable = mkDefault true;
    # $GNUPGHOME/trustdb.gpg stores all the trust level you specified in `programs.gpg.publicKeys` option. If set `mutableTrust` to false, the path $GNUPGHOME/trustdb.gpg will be overwritten on each activation. Thus we can only update trsutedb.gpg via home-manager.
    mutableTrust = mkDefault false;
    # $GNUPGHOME/pubring.kbx stores all the public keys you specified in `programs.gpg.publicKeys` option. If set `mutableKeys` to false, the path $GNUPGHOME/pubring.kbx will become an immutable link to the Nix store, denying modifications. Thus we can only update pubring.kbx via home-manager
    mutableKeys = lib.mkDefault false;
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
  services.gpg-agent = { # gpg agent with pinentry-qt
    enable = mkDefault true;
    pinentry.package = mkDefault pkgs.pinentry-curses;
    enableSshSupport = mkDefault true;
    defaultCacheTtl = mkDefault (4 * 60 * 60); # 4 hours
    sshKeys = mkDefault myvars.gpg2ssh_keygrip;
  };
  ## END gpg.nix
  systemd.user.services."${myvars.username}".environment.STNODEFAULTFOLDER = lib.mkDefault "true"; # Don't create default ~/Sync folder
  services = {
    udiskie.enable = mkDefault true; # auto mount usb drives
    syncthing.enable = mkDefault true;
    syncthing.tray.enable = mkDefault true;
  };
}
