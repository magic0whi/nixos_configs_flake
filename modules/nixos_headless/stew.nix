{lib, config, myvars, pkgs, ...}: {
  ## START bootloader.nix
  boot.loader.efi.canTouchEfiVariables = true; # Allow installation process to modify EFI boot variables
  boot.loader.systemd-boot = {
    enable = lib.mkDefault true;
    configurationLimit = 4; # Limit the boot loader entries
    consoleMode = "max";
  };
  ## END bootloader.nix
  ## START power_management.nix
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.logind.settings.Login.HandleLidSwitch = "ignore";
  ## END power_management.nix
  ## START nix.nix
  nix.gc.dates = "weekly";
  nix.settings.auto-optimise-store = true; # Optimise the store after each build
  # nix.extraOptions = ''
    # !include ${config.age.secrets.nix-access-tokens.path}
  # '';
  ## END nix.nix
  ## START ssh.nix
  services.openssh.settings.PasswordAuthentication = false; # Disable password login
  # The OpenSSH agent remembers private keys for you. So that you don’t have to type in passphrases every time you
  # make an SSH connection.
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
  ## START network.nix
  networking.useNetworkd = true;
  networking.nftables.enable = true;
  networking.firewall = {
    # enable = false;
    extraInputRules = ''
      ip saddr 192.168.15.0/24 accept comment "Allow from LAN"
      ip6 saddr { fe80::/16, fd66:06e5:aebe::/48 } accept comment "Allow from Link-Local / ULA-Prefix (IPv6)"
      iifname tun0 accept comment "Allow sing-box"
      tcp dport snapenetio accept comment "Allow Syncthing"
      udp dport { snapenetio, 21027 } accept comment "Allow Syncthing broadcasts (IPv4) / multicasts (IPv6)"
      tcp dport 53317 counter accept comment "Allow LocalSend (HTTP/TCP)"
      udp dport 53317 counter accept comment "Allow LocalSend (Multicast/UDP)"
      tcp dport 8888 accept comment "Allow Atuin"
      udp dport bootps accept comment "Allow DHCP server (systemd-nspawn)"
    '';
    filterForward = true;
    extraForwardRules = ''
      ip6 saddr { fe80::/16, fd66:06e5:aebe::/48 } counter accept comment "Allow forward from Link-Local / ULA-Prefix (IPv6)"
      ip6 saddr { 2409:8a20:5063:5c10::/60 } accept comment "Allow forward from SLAAC (IPv6)"
      ip6 daddr { 2409:8a20:5063:5c10::/60 } accept comment "Allow forward to SLAAC (IPv6)"
      iifname { tun0, "ve-*" } accept comment "Allow sing-box, systemd-nspawn container"
      oifname { tun0, "ve-*" } accept comment "Allow sing-box, systemd-nspawn container"
    '';
  };
  networking.timeServers = [ # Or
  # services.timesyncd.servers = [
    "ntp.aliyun.com" # Aliyun NTP Server
    "ntp.tencent.com" # Tencent NTP Server
  ];
  services.resolved.enable = true;

  # Override the sing-box's systemd service
  systemd.services.sing-box = lib.mkIf config.services.sing-box.enable (lib.mkOverride 100 {
    serviceConfig = {
      StateDirectory = "sing-box";
      StateDirectoryMode = "0700";
      RuntimeDirectory = "sing-box";
      RuntimeDirectoryMode = "0700";
      LoadCredential = [("config.json:" + config.age.secrets."config.json".path)];
      ExecStart = [
        "" # Empty value remove previous value
        (let configArgs = "-c $\{CREDENTIALS_DIRECTORY}/config.json";
          in "${lib.getExe config.services.sing-box.package} -D \${STATE_DIRECTORY} ${configArgs} run")
      ];
    };
    wantedBy = ["multi-user.target"];
  });
  # Tailscale stores its data in /var/lib/tailscale, which is persistent across reboots via impermanence.nix
  # Ref: https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/networking/tailscale.nix
  # 
  # Auto detect the firewall type (nftables)
  systemd.services.tailscaled.environment.TS_DEBUG_FIREWALL_MODE = "auto";
  services.tailscale = {
    openFirewall = true; # allow the Tailscale UDP port through the firewall
    useRoutingFeatures = "client"; # "server" if act as exit node
    # extraUpFlags = "--accept-routes";
    # authKeyFile = "/var/lib/tailscale/authkey";
  };
  ## END network.nix
  ## START remote_build.nix
  #  NixOS's Configuration for Remote Building / Distributed Building
  #
  #  Related Docs:
  #    1. https://github.com/NixOS/nix/issues/7380
  #    2. https://nixos.wiki/wiki/Distributed_build
  #    3. https://github.com/NixOS/nix/issues/2589
  #
  ####################################################################

  # set local's max-job to 0 to force remote building(disable local building)
  # nix.settings.max-jobs = 0;
  nix.distributedBuilds = true;
  nix.buildMachines = let # TODO
    sshUser = myvars.username;
    # ssh key's path on local machine
    sshKey = "/etc/agenix/ssh-key-romantic";
    systems = [
      # native arch
      "x86_64-linux"

      # emulated arch using binfmt_misc and qemu-user
      "aarch64-linux"
      "riscv64-linux"
    ];
    # all available system features are poorly documentd here:
    #  https://github.com/NixOS/nix/blob/e503ead/src/libstore/globals.hh#L673-L687
    supportedFeatures = [
      "benchmark"
      "big-parallel"
      "kvm"
    ];
  in [
    # Nix seems always try to build on the machine remotely
    # to make use of the local machine's high-performance CPU, do not set remote builder's maxJobs too high.
    # {
    #   # some of my remote builders are running NixOS
    #   # and has the same sshUser, sshKey, systems, etc.
    #   inherit sshUser sshKey systems supportedFeatures;
    #
    #   # the hostName should be:
    #   #   1. a hostname that can be resolved by DNS
    #   #   2. the ip address of the remote builder
    #   #   3. a host alias defined globally in /etc/ssh/ssh_config
    #   hostName = "aquamarine";
    #   # remote builder's max-job
    #   maxJobs = 3;
    #   # speedFactor's a signed integer
    #   # https://github.com/ryan4yin/nix-config/issues/70
    #   speedFactor = 1;
    # }
    # {
    #   inherit sshUser sshKey systems supportedFeatures;
    #   hostName = "ruby";
    #   maxJobs = 2;
    #   speedFactor = 1;
    # }
    # {
    #   inherit sshUser sshKey systems supportedFeatures;
    #   hostName = "kana";
    #   maxJobs = 2;
    #   speedFactor = 1;
    # }
  ];
  # optional, useful when the builder has a faster internet connection than yours
  nix.extraOptions = "builders-use-substitutes = true";
  ## END remote_build.nix
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
    mutableUsers = false; # Don't allow mutate users outside the config.
    groups = {
      "${myvars.username}" = {gid = 1000;};
      docker = {};
    };
    users."${myvars.username}" = {
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
      openssh.authorizedKeys.keys = myvars.ssh_authorized_keys;
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
      initialHashedPassword = config.users.users."${myvars.username}".initialHashedPassword;
      openssh.authorizedKeys.keys = config.users.users."${myvars.username}".openssh.authorizedKeys.keys;
    };
  };
  ## END users.nix
  ## START zram.nix
  zramSwap.enable = true;
  ## END zram.nix
  ## START fhs.nix
  # Create a fhs environment by command `fhs`, so we can run non-NixOS packages in # NixOS
  environment.systemPackages = [(let base = pkgs.appimageTools.defaultFhsEnvArgs;
  in pkgs.buildFHSEnv (base // {
    name = "fhs";
    targetPkgs = pkgs: (base.targetPkgs pkgs) ++ [pkgs.pkg-config];
    profile = "export FHS=1";
    runScript = "bash";
    extraOutputsToInstall = ["dev"];
  }))];
  # nix-ld will install itself at `/lib64/ld-linux-x86-64.so.2` so that it can be used as the dynamic linker for non-NixOS binaries.
  # Ref: https://github.com/Mic92/nix-ld
  # nix-ld works like a middleware between the actual link loader located at `/nix/store/.../ld-linux-x86-64.so.2`
  # and the non-NixOS binaries. It will:
  # 1. read the `NIX_LD` environment variable and use it to find the actual link loader.
  # 2. read the `NIX_LD_LIBRARY_PATH` environment variable and use it to set the `LD_LIBRARY_PATH` environment variable
  #    for the actual link loader.
  # nix-ld's nixos module will set default values for `NIX_LD` and `NIX_LD_LIBRARY_PATH` environment variables, so
  # it can work out of the box: https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/programs/nix-ld.nix#L37-L40
  #
  # You can overwrite `NIX_LD_LIBRARY_PATH` in the environment where you run the non-NixOS binaries to customize the
  # search path for shared libraries.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [pkgs.stdenv.cc.cc];
  ## END fhs.nix
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
    packages = with pkgs; [noto-fonts noto-fonts-emoji];
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
  ## START console.nix
  services.kmscon = { # https://wiki.archlinux.org/title/KMSCON
  # Use kmscon as the virtual console instead of gettys.
  # kmscon is a kms/dri-based userspace virtual terminal implementation.
  # It supports a richer feature set than the standard linux console VT,
  # including full unicode support, and when the video card supports drm should be much faster.
    enable = true;
    fonts = [{name = "Iosevka Nerd Font Mono"; package = pkgs.nerd-fonts.iosevka;}];
    hwRender = true; # Whether to use 3D hardware acceleration to render the console.
    extraOptions = "--term xterm-256color";
    extraConfig = ''font-size=12'';
  };
  ## START console.nix
  ## START security.nix
  security.sudo.package = (pkgs.sudo.override {withSssd = true;});
  security.sudo.extraConfig = ''Defaults passwd_timeout=0''; # Disable timeout for sudo prompt
  system.nssDatabases.sudoers = ["sss"]; # Use LDAP to distribute configuration of sudo as well
  services.sssd = {
    # enable = true; # TODO
    config = ''
    [sssd]
    config_file_version = 2
    services = nss, pam, sudo
    domains = LDAP

    [domain/LDAP]
    cache_credentials = true
    entry_cache_timeout = 600
    enumerate = true

    id_provider = ldap
    auth_provider = ldap
    chpass_provider = ldap

    ldap_uri = ldaps://proteusdesktop.tailba6c3f.ts.net:636
    ldap_search_base = dc=tailba6c3f,dc=ts,dc=net
    ldap_sudo_search_base = ou=Sudoers,dc=tailba6c3f,dc=ts,dc=net
    ldap_tls_reqcert = demand
    ldap_network_timeout = 2
    ldap_schema = rfc2307bis
    '';
  };
  ## END security.nix
  ## START tor.nix
  services.tor = {
    enable = true;
    client.enable = true;
    # openFirewall = true;
    settings = {
      ExitNodes = "{GB}";
      ExitPolicy = ["accept *:*"];
      AvoidDiskWrites = 1;
      HardwareAccel = 1;
      UseBridges = true;
      ClientTransportPlugin = "snowflake exec ${lib.getExe' pkgs.snowflake "client"} -url https://snowflake-broker.azureedge.net/ -front ajax.aspnetcdn.com -ice stun:stun.l.google.com:19302,stun:stun.antisip.com:3478,stun:stun.bluesip.net:3478,stun:stun.dus.net:3478,stun:stun.epygi.com:3478,stun:stun.sonetel.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.voys.nl:3478 utls-imitate=hellorandomizedalpn -log /tmp/snowflake-client.log";
      Bridge = [
        "snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72 fingerprint=2B280B23E1107BB62ABFC40DDCC8824814F80A72 url=https://1098762253.rsc.cdn77.org/ fronts=www.cdn77.com,www.phpmyadmin.net ice=stun:stun.l.google.com:19302,stun:stun.antisip.com:3478,stun:stun.bluesip.net:3478,stun:stun.dus.net:3478,stun:stun.epygi.com:3478,stun:stun.sonetel.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.voys.nl:3478 utls-imitate=hellorandomizedalpn"
        "snowflake 192.0.2.4:80 8838024498816A039FCBBAB14E6F40A0843051FA fingerprint=8838024498816A039FCBBAB14E6F40A0843051FA url=https://1098762253.rsc.cdn77.org/ fronts=www.cdn77.com,www.phpmyadmin.net ice=stun:stun.l.google.com:19302,stun:stun.antisip.com:3478,stun:stun.bluesip.net:3478,stun:stun.dus.net:3478,stun:stun.epygi.com:3478,stun:stun.sonetel.net:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.voys.nl:3478 utls-imitate=hellorandomizedalpn"
      ];
    };
  };
  ## END tor.nix
  ## START i2pd.nix
  services.i2pd = {
    enable = true;
    enableIPv6 = true;
    upnp.enable = true;
    reseed = {
      verify = true;
      proxy = "socks://127.0.0.1:2080";
      urls = [
        "https://reseed.i2p-projekt.de/"
        "https://i2p.mooo.com/netDb/"
        "https://netdb.i2p2.no/"
      ];
    };
    proto = {
      http.enable = true;
      httpProxy.enable = true;
      socksProxy.enable = true;
    };
  };
  ## END i2pd.nix
}
