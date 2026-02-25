{lib, config, myvars, pkgs, ...}: {
  ## START bootloader.nix
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true; # Allow installation process to modify EFI boot variables
  boot.loader.systemd-boot = {
    enable = lib.mkDefault true;
    configurationLimit = 4; # Limit the boot loader entries
    consoleMode = "max";
  };
  ## END bootloader.nix
  ## START nix.nix
  nix.gc.dates = "weekly";
  nix.settings.auto-optimise-store = true; # Optimise the store after each build
  # nix.extraOptions = ''
    # !include ${config.age.secrets.nix-access-tokens.path}
  # '';
  ## END nix.nix
  ## START ssh.nix
  services.openssh.settings.PasswordAuthentication = false; # Disable password login
  programs.ssh.extraConfig = ''
    Host *
      IdentityAgent /run/user/${builtins.toString config.users.users.${myvars.username}.uid}/gnupg/S.gpg-agent.ssh
  '';
  # The OpenSSH agent remembers private keys for you. So that you don’t have to
  # type in passphrases every time you make an SSH connection.
  # Use `ssh-add` to add a key to the agent.
  # NOTE: You cannot use ssh-agent and GnuPG agent with SSH support at the same time
  # ssh.startAgent = true;
  ## END ssh.nix
  ## START i18n.nix
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # i18n.extraLocaleSettings = {
    # LC_ADDRESS = "en_US.UTF-8";
    # LC_IDENTIFICATION = "en_US.UTF-8";
    # LC_MEASUREMENT = "en_US.UTF-8";
    # LC_MONETARY = "en_US.UTF-8";
    # LC_NAME = "en_US.UTF-8";
    # LC_NUMERIC = "en_US.UTF-8";
    # LC_PAPER = "en_US.UTF-8";
    # LC_TELEPHONE = "en_US.UTF-8";
    # LC_TIME = "en_US.UTF-8";
  # };
  ## END i18n.nix
  ## START sysctl.nix
  boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
  boot.kernel.sysctl."net.core.default_qdisc" = "cake";
  ## END sysctl.nix
  ## START network.nix
  networking.useNetworkd = true;
  networking.nftables.enable = true;
  networking.firewall = {
    # enable = false; # Disable firewall
    extraInputRules = ''
      # ip saddr 192.168.1.0/24 accept comment "Allow from LAN"
      ip6 saddr { fe80::/16, fd66:06e5:aebe::/48 } accept comment "Allow from Link-Local / ULA-Prefix (IPv6)"
      udp dport bootps accept comment "Allow DHCP server (systemd-nspawn)"
    '';
  };
  networking.timeServers = [ # Or
  # services.timesyncd.servers = [
    "ntp.aliyun.com" # Aliyun NTP Server
    "ntp.tencent.com" # Tencent NTP Server
  ];
  services.resolved.enable = true;

  # Tailscale stores its data in /var/lib/tailscale, which is persistent across reboots via impermanence.nix
  # Ref: https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/networking/tailscale.nix

  # Auto detect the firewall type (nftables)
  systemd.services.tailscaled.environment.TS_DEBUG_FIREWALL_MODE = "auto";
  services.tailscale = {
    openFirewall = true; # allow the Tailscale UDP port through the firewall
    useRoutingFeatures = "client"; # "server" if act as exit node
    # extraUpFlags = "--accept-routes";
    # authKeyFile = "/var/lib/tailscale/authkey";
  };
  ## END network.nix
  ## START shell.nix
  programs.zsh = {
    autosuggestions = {
      enable = true;
      highlightStyle = "fg=60";
      strategy = ["match_prev_cmd" "history" "completion"];
    };
    syntaxHighlighting.enable = true;
  };
  ## END shell.nix
  ## START users.nix
  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false; # Don't allow mutate users outside the config
    groups = {
      ${myvars.username} = {gid = 1000;};
      docker = {};
    };
    users.${myvars.username} = {
      # Public Keys that can be used to login to all my PCs, Macbooks, and servers.
      #
      # Since its authority is so large, we must strengthen its security:
      # - The corresponding private key must be:
      #   1. Generated locally on every trusted client via:
      #     ```bash
      #     # KDF: bcrypt with 256 rounds, takes 2s on Apple M2):
      #     # Passphrase: digits + letters + symbols, 12+ chars
      #     ssh-keygen -t ed25519 -a 256 -C "ryan@xxx" -f ~/.ssh/xxx`
      #     ```
      #   2. Never leave the device and never sent over the network.
      # - Or just use hardware security keys like Yubikey/CanoKey.
      uid = 1000;
      home = "/home/${myvars.username}";
      initialHashedPassword = myvars.initial_hashed_password;
      isNormalUser = true;
      extraGroups = [
        myvars.username
        "docker"
        "input"
        "libvirtd"
        "network"
        "video"
        "wheel"
      ];
    };
    users.root = { # root's ssh key are heavily used for remote deployment
      initialHashedPassword = lib.mkDefault config.users.users."${myvars.username}".initialHashedPassword;
      openssh.authorizedKeys.keys = config.users.users."${myvars.username}".openssh.authorizedKeys.keys;
    };
  };
  ## END users.nix
  ## START zram.nix
  zramSwap.enable = true;
  ## END zram.nix
  systemd.services.console-blanking = { # Let monitor become blank after 2mins, and 3mins inactive to
  # poweroff
    description = "Enable virtual console blanking and DPMS";
    after = ["display-manager.service"];
    environment = {TERM = "linux";};
    serviceConfig = {
      Type = "oneshot";
      StandardOutput = "tty";
      TTYPath = "/dev/console";
      ExecStart = "${lib.getExe' pkgs.util-linux "setterm"} --blank 2 --powerdown 3";
    };
    wantedBy = ["multi-user.target"];
  };
  ## START fonts.nix
  fonts = { # All fonts are linked to /nix/var/nix/profiles/system/sw/share/X11/fonts
    fontDir.enable = true;
    packages = with pkgs; [noto-fonts noto-fonts-color-emoji];
    fontconfig = {
      subpixel.rgba = "rgb";
      defaultFonts = {
        serif = ["Noto Serif" "FZYaSongS-R-GB" "Noto Serif CJK SC" "Noto Serif CJK TC" "Noto Serif CJK JP"];
        sansSerif = ["Inter Nerd Font" "Noto Sans" "Noto Sans CJK SC" "Noto Sans CJK TC" "Noto Sans CJK JP"];
        monospace = [
          "Iosevka Nerd Font Mono"
          "Noto Sans Mono"
          "Noto Sans Mono CJK SC"
          "Noto Sans Mono CJK TC"
          "Noto Sans Mono CJK JP"
        ];
        emoji = ["Noto Color Emoji"];
      };
    };
  };
  ## END fonts.nix
  ## START security.nix
  # Without polkit, sing-box can't interact with systemd-resolved
  security.polkit.enable = true;
  security.sudo.package = (pkgs.sudo.override {withSssd = true;});
  security.sudo.extraConfig = ''Defaults passwd_timeout=0''; # Disable timeout for sudo prompt
  system.nssDatabases.sudoers = ["sss"]; # Use LDAP to distribute configuration of sudo as well
  services.sssd = {
    enable = true;
    settings = {
    sssd = {
      debug_level = 7;
      services = "ifp, nss, pam, sudo";
      domains = "LDAP";
    };
    "pam".pam_verbosity = 3;
    "domain/LDAP" = {
      override_shell = "/run/current-system/sw/bin/${config.users.defaultUserShell.meta.mainProgram}";
      cache_credentials = true;
      entry_cache_timeout = 600;
      enumerate = true;

      id_provider = "ldap";
      auth_provider = "ldap";
      chpass_provider = "ldap";

      ldap_uri = "ldaps://proteus-nuc.tailba6c3f.ts.net:636";
      ldap_search_base = "dc=tailba6c3f,dc=ts,dc=net";
      ldap_sudo_search_base = "ou=Sudoers,dc=tailba6c3f,dc=ts,dc=net";
      ldap_tls_reqcert = "demand";
      ldap_network_timeout = 2;
      ldap_schema = "rfc2307bis";
    };
    };
  };
  ## END security.nix
}
