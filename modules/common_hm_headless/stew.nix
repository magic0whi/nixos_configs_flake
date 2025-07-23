{myvars, pkgs, pgp2ssh, ...}: {
  # This value determines the Home Manager release that your configuration is compatible with. This helps avoid
  # breakage when a new Home Manager release introduces backwards incompatible changes.
  #
  # You can update Home Manager without changing this value. See the Home Manager release notes for a list of state
  # version changes in each release.
  home.stateVersion = myvars.nixos_state_version;
  programs.home-manager.enable = true; # Let Home Manager install and manage itself.
  home.packages = with pkgs; [
    ## Misc
    fastfetch
    cowsay
    gnumake
    pgp2ssh.packages.${pkgs.system}.pgp2ssh

    ## Modern cli tools, replacement of grep/sed/...
    # A fast and polyglot tool for code searching, linting, rewriting at large scale
    # supported languages: only some mainstream languages currently (don't support nix/nginx/yaml/toml/...)
    ast-grep

    sad # CLI search and replace, just like sed, but with diff preview.
    yq-go # yaml processor https://github.com/mikefarah/yq
    just # a command runner like make, but simpler
    lazygit # Git terminal UI.
    hyperfine # command-line benchmarking tool, replace `time`
    gping # ping, but with a graph (TUI)
    doggo # DNS client for humans
    duf # Disk Usage/Free Utility - a better 'df' alternative
    du-dust # A more intuitive version of `du` in rust
    ncdu # Analyzer your disk usage Interactively, via TUI (replacement of `du`)
    gdu # Disk usage analyzer(replacement of `du`)

    ## Nix related
    nix-output-monitor # Command `nom`, works just like `nix` with more fancy output
    hydra-check # Check hydra (nix's build farm) for the build status of a package
    nix-index # A small utility to index nix store paths
    nix-init # Generate nix derivation from url
    nix-melt # A TUI flake.lock viewer, ref: https://github.com/nix-community/nix-melt
    nix-tree # A TUI to visualize the dependency graph of a nix derivation, ref: https://github.com/utdemir/nix-tree

    # Productivity
    caddy # A webserver with automatic HTTPS via Let's Encrypt(replacement of nginx)
    croc # File transfer between computers securely and easily

    libnotify # notify-send
    wireguard-tools # manage wireguard vpn manually, via wg-quick

    # ventoy # create bootable usb

    # Benchmark
    xmrig
  ];
  ## START pip.nix
  # Use mirror for pip install
  xdg.configFile."pip/pip.conf".text = ''
  [global]
  index-url = https://mirror.nju.edu.cn/pypi/web/simple
  format = columns
  '';
  ## END pip.nix
  ## START btop.nix
  # https://github.com/catppuccin/btop/blob/main/themes/catppuccin_mocha.theme
  xdg.configFile."btop/themes".source = "${pkgs.catppuccin}/btop/";
  programs.btop = { # Alternative to htop/nmon
    enable = true;
    settings = {
      color_theme = "catppuccin_${myvars.catppuccin_variant}";
      theme_background = false; # Make btop transparent
    };
  };
  ## END btop.nix
  ## START yazi.nix
  # xdg.configFile."yazi/theme.toml".source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-yazi}/mocha.toml";
  programs.yazi = { # terminal file manager
    enable = true;
    # enableZshIntegration = false; # Don't changing working directory when exiting Yazi
    settings = {
      manager = {
        show_hidden = true;
        sort_dir_first = true;
      };
    };
  };
  ## END yazi.nix
}
