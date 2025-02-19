{myvars, ...}: {
  imports = [./common ./desktop];
  boot.loader.systemd-boot = {
    # We use Git for version control, so we don't need to keep too many generations.
    configurationLimit = 10;
    # Pick the highest resolution for systemd-boot's console.
    consoleMode = "max";
  };
  boot.loader.timeout = 8; # wait for x seconds to select the boot entry

  environment.variables.EDITOR = "nvim --clean";

  # for power management
  services = {
    power-profiles-daemon.enable = true;
    upower.enable = true;
  };

  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
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

  # Add my self-signed CA certificate to the system-wide trust store.
  security.pki.certificateFiles = [../../custom_files/proteus_ca.pem];

  services.timesyncd.servers = [
    "ntp.aliyun.com" # Aliyun NTP Server
    "ntp.tencent.com" # Tencent NTP Server
  ];
  networking.firewall.enable = false; # Disable the firefall

  nixpkgs.config.allowUnfree = true; # Enable unfree packages to install chrome

  nix.gc = { # Do garbage collection weekly to keep disk usage low
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  # Manual optimise storage: nix-store --optimise
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings.auto-optimise-store = true;

  nix.settings = {
    # enable flakes globally
    experimental-features = ["nix-command" "flakes"];

    # given the users in this list the right to specify additional substituters via:
    #    1. `nixConfig.substituers` in `flake.nix`
    #    2. command line args `--options substituers http://xxx`
    trusted-users = [myvars.username];

    # substituers that will be considered before the official ones(https://cache.nixos.org)
    substituters = [
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

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "ryan4yin.cachix.org-1:Gbk27ZU5AYpGS9i3ssoLlwdvMIh0NxG0w8it/cv9kbU="
    ];
    builders-use-substitutes = true;
  };

  # nix.extraOptions = ''
    # !include ${config.age.secrets.nix-access-tokens.path}
  # '';

  nix.channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.

  programs.ssh = myvars.networking.ssh;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false; # disable password login
  };

  zramSwap = {
    enable = true;
    # one of "lzo", "lz4", "zstd"
    algorithm = "zstd";
    # Priority of the zram swap devices.
    # It should be a number higher than the priority of your disk-based swap devices
    # (so that the system will fill the zram swap devices before falling back to disk swap).
    priority = 5;
    # Maximum total amount of memory that can be stored in the zram swap devices (as a percentage of your total memory).
    # Defaults to 1/2 of your total RAM. Run zramctl to check how good memory is compressed.
    # This doesn’t define how much memory will be used by the zram swap devices.
    memoryPercent = 50;
  };
}
