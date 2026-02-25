{myvars, pkgs, lib, ...}: {
  # This value determines the Home Manager release that your configuration is compatible with. This helps avoid
  # breakage when a new Home Manager release introduces backwards incompatible changes.
  #
  # You can update Home Manager without changing this value. See the Home Manager release notes for a list of state
  # version changes in each release.
  home.stateVersion = myvars.nixos_state_version;
  programs.home-manager.enable = true; # Let Home Manager install and manage itself.
  home.packages = with pkgs; [
    fastfetch
    ## Modern cli tools, replacement of grep/sed/...
    # A fast and polyglot tool for code searching, linting, rewriting at large scale
    # supported languages: only some mainstream languages currently (don't support nix/nginx/yaml/toml/...)
    ast-grep
    sad # CLI search and replace, just like sed, but with diff preview.
    lazygit # Git terminal UI.
    hyperfine # command-line benchmarking tool, replace `time`
    gping # ping, but with a graph (TUI)
    doggo # DNS client for humans
    duf # Disk Usage/Free Utility - a better 'df' alternative
    dust # A more intuitive version of `du` in rust
    ncdu # Analyzer your disk usage Interactively, via TUI (replacement of `du`)
    gdu # Disk usage analyzer(replacement of `du`)

    ## Nix related
    hydra-check # Check hydra (nix's build farm) for the build status of a package
    nix-index # A small utility to index nix store paths
    nix-init # Generate nix derivation from url
    nix-melt # A TUI flake.lock viewer, ref: https://github.com/nix-community/nix-melt
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isRiscV64) [ # TODO: Requires bootstrap GHC
    nix-output-monitor # Command `nom`, works just like `nix` with more fancy output
    nix-tree # A TUI to visualize the dependency graph of a nix derivation, ref: https://github.com/utdemir/nix-tree
  ];
  ## START syncthing.nix
  services.syncthing.enable = lib.mkDefault true;
  systemd.user.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  launchd.agents.syncthing.config.EnvironmentVariables.STNODEFAULTFOLDER = "true";
  ## END syncthing.nix
  ## START pip.nix
  # Use mirror for pip install
  xdg.configFile."pip/pip.conf".text = ''
    [global]
    index-url = https://mirror.nju.edu.cn/pypi/web/simple
    format = columns
  '';
  ## END pip.nix
  ## START btop.nix
  programs.btop = { # Alternative to htop/nmon
    enable = true;
    settings.theme_background = false; # Make btop transparent
  };
  ## END btop.nix
  ## START yazi.nix
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
  ## START direnv.nix
  # programs.direnv = {
  #   enable = true;
  #   nix-direnv.enable = true;
  # };
  ## END direnv.nix
  ## START neovim.nix
  # programs.neovim = {
  #   enable = true;
  #   viAlias = true;
  #   vimAlias = true;
  # };
  ## END neovim.nix
  ## START gpg.nix
  programs.gpg = {
    publicKeys = [ # https://www.gnupg.org/gph/en/manual/x334.html
      {source = "${myvars.secrets_dir}/${myvars.useremail}.pub.asc"; trust = 5; /*ultimate trust, my own keys*/}
    ];
    enable = true;
    # $GNUPGHOME/trustdb.gpg stores all the trust level you specified in `programs.gpg.publicKeys` option. If set
    # `mutableTrust` to false, the path $GNUPGHOME/trustdb.gpg will be overwritten on each activation. Thus we can only
    # update trsutedb.gpg via home-manager
    mutableTrust = true;
    # $GNUPGHOME/pubring.kbx stores all the public keys you specified in `programs.gpg.publicKeys` option. If set
    # `mutableKeys` to false, the path $GNUPGHOME/pubring.kbx will become an immutable link to the Nix store, denying
    # modifications. Thus we can only update pubring.kbx via home-manager
    mutableKeys = true;
    # This configuration is based on the tutorial https://blog.eleven-labs.com/en/openpgp-almost-perfect-key-pair-part-1
    # , it allows for a robust setup
    settings = {
      no-greeting = true; # Get rid of the copyright notice
      no-emit-version = true; # Disable inclusion of the version string in ASCII armored output
      no-comments = false; # Do not write comment packets
      # Export the smallest key possible. This removes all signatures except the most recent self-signature on each
      # user ID
      export-options = "export-minimal";
      keyid-format = "0xlong"; # Display long key IDs
      with-fingerprint = true; # List all keys (or the specified ones) along with their fingerprints
      list-options = "show-uid-validity"; # Display the calculated validity of user IDs during key listings
      verify-options = "show-uid-validity show-keyserver-urls";
      personal-cipher-preferences = "AES256"; # Select the strongest cipher
      personal-digest-preferences = "SHA512"; # Select the strongest digest
      # This preference list is used for new keys and becomes the default for "setpref" in the edit menu
      default-preference-list = "SHA512 SHA384 SHA256 RIPEMD160 AES256 TWOFISH BLOWFISH ZLIB BZIP2 ZIP Uncompressed";

      cipher-algo = "AES256"; # Use the strongest cipher algorithm
      digest-algo = "SHA512"; # Use the strongest digest algorithm
      cert-digest-algo = "SHA512"; # Message digest algorithm used when signing a key
      compress-algo = "ZLIB"; # Use RFC-1950 ZLIB compression

      disable-cipher-algo = "3DES"; # Disable weak algorithm
      weak-digest = "SHA1"; # Treat the specified digest algorithm as weak

      # The cipher algorithm for symmetric encryption for symmetric encryption with a passphrase
      s2k-cipher-algo = "AES256";
      s2k-digest-algo = "SHA512"; # The digest algorithm used to mangle the passphrases for symmetric encryption
      s2k-mode = "3"; # Selects how passphrases for symmetric encryption are mangled
      # Specify how many times the passphrases mangling for symmetric encryption is repeated
      s2k-count = "65011712";
    };
  };
  services.gpg-agent = {
    enable = true;
    pinentry.package = lib.mkDefault pkgs.pinentry-curses;
    enableSshSupport = true;
    defaultCacheTtl = (4 * 60 * 60); # 4 hours
    sshKeys = myvars.gpg2ssh_keygrip; # Run 'gpg --export-ssh-key gpg-key!' to export public key
  };
  ## END gpg.nix
  ## START catppuccin.nix
  catppuccin = { # Enable Catppuccin globally
    enable = lib.mkDefault true;
    accent = myvars.catppuccin_accent;
    flavor = myvars.catppuccin_flavor;
  };
  ## END catppuccin.nix
}
