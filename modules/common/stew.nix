{lib, pkgs, myvars, ...}: {
  system.stateVersion = if pkgs.stdenv.isDarwin then myvars.darwin_state_version else myvars.nixos_state_version;
  # Add my self-signed CA certificate to the system-wide trust store.
  security.pki.certificateFiles = [("${myvars.secrets_dir}/proteus_ca.pub.pem")];
  nixpkgs.config.allowUnfree = true; # Allow chrome, vscode to install
  ## START nix.nix
  nix.package = pkgs.nixVersions.latest; # Use latest nix, default is pkgs.nix
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
  };
  nix.channel.enable = false; # Remove nix-channel related tools & configs, use flakes instead
  # Manual optimise storage: nix-store --optimise
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.optimise.automatic = true; # Add a timer to do optimise periodically
  nix.settings = {
    # enable flakes globally
    experimental-features = ["nix-command" "flakes"];

    # Given the users in this list the right to specify additional substituters via:
    # 1. `nixConfig.substituers` in `flake.nix`
    # 2. command line args `--options substituers http://xxx`
    trusted-users = [myvars.username];
    substituters = [ # substituers that will be considered before the official ones (https://cache.nixos.org)
      # cache mirror located in China
      # status: https://mirrors.ustc.edu.cn/status/
      # "https://mirrors.ustc.edu.cn/nix-channels/store"
      # status: https://mirror.sjtu.edu.cn/
      # "https://mirror.sjtu.edu.cn/nix-channels/store"
      # others
      "https://mirrors.sustech.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"

      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
    builders-use-substitutes = true;
    sandbox = true;
  };
  ## END nix.nix
  ## START i18n.nix
  # NOTE: On macOS, Please set [Set time zone automatically using your current location] to false in [System Settings]
  time.timeZone = lib.mkDefault "Asia/Hong_Kong";
  ## END i18n.nix
  ## START ssh.nix
  services.openssh.enable = true;
  programs.ssh = {
    # Configs will be written to /etc/ssh/ssh_config
    extraConfig = lib.mkMerge [
      (lib.mkBefore ''
        Compression yes
        ControlMaster auto
        ControlPath ~/.ssh/master-%r@%n:%p
        ControlPersist 30m
        ServerAliveInterval 30
        ServerAliveCountMax 5
      '')
      (lib.mkAfter (lib.attrsets.foldlAttrs (acc: host: val: acc + ''
        Host ${host}
          Hostname ${if (builtins.isNull myvars.networking.hosts_addr.${host}.ipv4) then host else val.ipv4}
          Port 22
        '')
        ""
        myvars.networking.hosts_addr
      ))
    ];
    # Define the host key for remote builders so that nix can verify all the
    # remote builders.
    # This config will be written to /etc/ssh/ssh_known_hosts
    knownHosts = lib.attrsets.mapAttrs (name: val: {
      hostNames = [name] # Hostname and its IPv4
      ++ (lib.optional
        (!builtins.isNull myvars.networking.hosts_addr.${name}.ipv4)
        myvars.networking.hosts_addr.${name}.ipv4
      );
      publicKey = val.public_key;
      })
      myvars.networking.known_hosts;
  };
  ## END ssh.nix
  ## START users.nix
  users.users.${myvars.username} = {
    description = myvars.userfullname;
    openssh.authorizedKeys.keys = myvars.ssh_authorized_keys;
  };
  ## END users.nix
  ## START network.nix
  services.tailscale.enable = lib.mkDefault true; # Start-up: `tailscale up --accept-routes`
  services.sing-box.package = pkgs.sing-box.overrideAttrs(final: _: {
    version = "1.13.0-rc.6";
    src = pkgs.fetchFromGitHub {
      owner = "SagerNet";
      repo = "sing-box";
      tag = "v${final.version}";
      hash = "sha256-yNZGUiNZh7fyW/BFgXcZg4ttnldRIDkB2KJ/MK5NH5E=";
    };
    vendorHash = "sha256-wBOu2Zac/PpUYKOxA5M56cyKdCLG2dQkBagKaGD8r4w=";
  });
  ## END network.nix
  ## START fonts.nix
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans noto-fonts-cjk-serif
    inter-nerdfont # NerdFont patch of the Inter font
    # nerdfonts
    # Ref: https://github.com/NixOS/nixpkgs/blob/nixos-unstable-small/pkgs/data/fonts/nerd-fonts/manifests/fonts.json
    nerd-fonts.symbols-only # symbols icon only
    nerd-fonts.iosevka
  ];
  ## END fonts.nix
  ## START packages.nix
  environment.systemPackages = with pkgs; [
    ## Core tools
    git # Used by nix flakes

    # Misc
    findutils
    tree
    gnutar
    rsync
    gnugrep # GNU grep, provides `grep`/`egrep`/`fgrep`
    curl
    # aria2 # A lightweight multi-protocol & multi-source command-line download utility
  ];
  ## END packages.nix
}
