{mylib, myvars, lib, config, pkgs, ...}: {
  imports = mylib.scan_path ./.;
  environment.variables.EDITOR = lib.mkOverride 999 "hx";
  # START boot_loader.nix
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true; # Allow installation process to modify EFI boot variables
  boot.loader.systemd-boot = {
    enable = lib.mkDefault true;
    configurationLimit = lib.mkDefault 10; # Limit the boot loader entries
    consoleMode = lib.mkDefault "max";
  };
  services = {
    power-profiles-daemon.enable = lib.mkDefault true;
    upower.enable = lib.mkDefault true;
  };
  # END boot_loader.nix
  # START nix.nix
  nixpkgs.config.allowUnfree = lib.mkDefault true; # Allow chrome, vscode to install
  nix.package = lib.mkDefault pkgs.nixVersions.latest; # Use latest nix, default is pkgs.nix
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };
  nix.channel.enable = lib.mkDefault false; # remove nix-channel related tools & configs, use flakes instead.
  nix.settings = {
    # Manual optimise storage: nix-store --optimise
    # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
    auto-optimise-store = lib.mkDefault true;
    # enable flakes globally
    experimental-features = lib.mkDefault ["nix-command" "flakes"];

    # given the users in this list the right to specify additional substituters via:
    #    1. `nixConfig.substituers` in `flake.nix`
    #    2. command line args `--options substituers http://xxx`
    trusted-users = lib.mkDefault [myvars.username];

    # substituers that will be considered before the official ones(https://cache.nixos.org)
    substituters = lib.mkDefault [
      # cache mirror located in China
      # status: https://mirrors.ustc.edu.cn/status/
      # "https://mirrors.ustc.edu.cn/nix-channels/store"
      # status: https://mirror.sjtu.edu.cn/
      # "https://mirror.sjtu.edu.cn/nix-channels/store"
      # others
      "https://mirrors.sustech.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"

      "https://nix-community.cachix.org"
      # my own cache server, currently not used.
      # "https://ryan4yin.cachix.org"
    ];

    trusted-public-keys = lib.mkDefault [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "ryan4yin.cachix.org-1:Gbk27ZU5AYpGS9i3ssoLlwdvMIh0NxG0w8it/cv9kbU="
    ];
    builders-use-substitutes = lib.mkDefault true;
  };

  # nix.extraOptions = ''
    # !include ${config.age.secrets.nix-access-tokens.path}
  # '';
  # END nix.nix
  # START ssh.nix
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
  services.openssh = {
    enable = lib.mkDefault true;
    settings.PasswordAuthentication = lib.mkDefault false; # disable password login
  };
  # END ssh.nix
  # START i18n.nix
  time.timeZone = lib.mkDefault "Asia/Shanghai";
  # Select internationalisation properties.
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  # i18n.extraLocaleSettings = {
    # LC_ADDRESS = "zh_CN.UTF-8";
    # LC_IDENTIFICATION = "zh_CN.UTF-8";
    # LC_MEASUREMENT = "zh_CN.UTF-8";
    # LC_MONETARY = "zh_CN.UTF-8";
    # LC_NAME = "zh_CN.UTF-8";
    # LC_NUMERIC = "zh_CN.UTF-8";
    # LC_PAPER = "zh_CN.UTF-8";
    # LC_TELEPHONE = "zh_CN.UTF-8";
    # LC_TIME = "zh_CN.UTF-8";
  # };
  # END i18n.nix
  # START networking.nix
  networking.useNetworkd = lib.mkDefault true;
  networking.nftables.enable = lib.mkDefault true;
  networking.firewall = {
    # enable = lib.mkDefault false;
    extraInputRules = ''
      ip saddr 192.168.15.0/24 accept comment "Allow from LAN"
      ip6 saddr { fe80::/16, fd66:06e5:aebe::/48 } accept comment "Allow from Link-Local / ULA-Prefix (IPv6)"
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
    '';
  };
  networking.timeServers = lib.mkDefault [ # Or
  # services.timesyncd.servers = [
    "ntp.aliyun.com" # Aliyun NTP Server
    "ntp.tencent.com" # Tencent NTP Server
  ];
  services.resolved.enable = lib.mkDefault true;
  # END networking.nix
  # START remote-building.nix
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
  nix.distributedBuilds = lib.mkDefault true;
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
  nix.extraOptions = lib.mkDefault ''
    builders-use-substitutes = true
  '';
  # END remote-building.nix
  # START users-n-groups.nix
  programs.zsh.enable = lib.mkDefault true;
  users = {
    defaultUserShell = lib.mkOverride 999 pkgs.zsh; # set users' default shell system-wide
    mutableUsers = lib.mkDefault false; # Don't allow mutate users outside the config.
    groups = lib.mkDefault {
      "${myvars.username}" = {};
      docker = {};
    };
    users."${myvars.username}" = {
      description = lib.mkDefault myvars.userfullname;
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
      openssh.authorizedKeys.keys = lib.mkDefault myvars.ssh_authorized_keys;
      initialHashedPassword = lib.mkDefault myvars.initial_hashed_password;
      home = lib.mkDefault "/home/${myvars.username}";
      isNormalUser = lib.mkDefault true;
      extraGroups = lib.mkDefault [
        # myvars.username # TODO may unnecessary
        # "users"
        "wheel"
        "docker"
        "libvirtd"
      ];
    };
    # root's ssh key are mainly used for remote deployment
    users.root = {
      # An example to prevent use the recursive attribute set
      initialHashedPassword = lib.mkDefault config.users.users."${myvars.username}".initialHashedPassword;
      openssh.authorizedKeys.keys = lib.mkDefault config.users.users."${myvars.username}".openssh.authorizedKeys.keys;
    };
  };
  # END users-n-groups.nix
  # START zram.nix
  zramSwap.enable = lib.mkDefault true;
  # END zram.nix
  # Add my self-signed CA certificate to the system-wide trust store.
  security.pki.certificateFiles = lib.mkDefault [
    (mylib.relative_to_root "custom_files/proteus_ca.pem")
  ];
  ## START fhs.nix
  # create a fhs environment by command `fhs`, so we can run non-nixos packages in nixos!
  environment.systemPackages = lib.mkDefault [(
  let
    base = pkgs.appimageTools.defaultFhsEnvArgs;
  in
    pkgs.buildFHSEnv (base // {
      name = "fhs";
      targetPkgs = pkgs: (base.targetPkgs pkgs) ++ [pkgs.pkg-config];
      profile = "export FHS=1";
      runScript = "bash";
      extraOutputsToInstall = ["dev"];
    })
  )];
  # https://github.com/Mic92/nix-ld
  # nix-ld will install itself at `/lib64/ld-linux-x86-64.so.2` so that
  # it can be used as the dynamic linker for non-NixOS binaries.
  #
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
  programs.nix-ld.enable = lib.mkDefault true;
  programs.nix-ld.libraries = lib.mkDefault [pkgs.stdenv.cc.cc];
  ## END fhs.nix
  ## START misc.nix
  # fix for `sudo xxx` in kitty/wezterm/foot and other modern terminal emulators
  # security.sudo.keepTerminfo = true;
  ## END misc.nix
}
