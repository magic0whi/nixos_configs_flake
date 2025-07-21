{mylib, lib, pkgs, myvars, ...}: {
  imports = mylib.scan_path ./.;
  # Add my self-signed CA certificate to the system-wide trust store.
  security.pki.certificateFiles = [(mylib.relative_to_root "custom_files/proteus_ca.pem")];
  nixpkgs.config.allowUnfree = lib.mkDefault true; # Allow chrome, vscode to install
  ## START nix.nix
  nix.package = lib.mkDefault pkgs.nixVersions.latest; # Use latest nix, default is pkgs.nix
  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 7d";
  };
  nix.channel.enable = lib.mkDefault false; # Remove nix-channel related tools & configs, use flakes instead
  # Manual optimise storage: nix-store --optimise
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.optimise.automatic = lib.mkDefault true; # Add a timer to do optimise periodically
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
    builders-use-substitutes = lib.mkDefault true;
    sandbox = lib.mkDefault true;
  };
  ## END nix.nix
  ## START ssh.nix
  services.openssh = {
    enable = lib.mkDefault true;
    # settings.PasswordAuthentication = mkDefault false; # Disable password login (not in darwin-nix yet)
  };
    programs.ssh = {
    extraConfig = lib.mkDefault (''
      Compression yes
      ControlMaster auto
      ControlPath ~/.ssh/master-%r@%n:%p
      ControlPersist 30m
      ServerAliveInterval 30
      ServerAliveCountMax 5
    '' + myvars.networking.ssh.extra_config);
    knownHosts = lib.mkDefault myvars.networking.ssh.known_hosts;
  };
  ## END ssh.nix
}
