{myvars, pkgs, config, lib, ...}: let
  homebrew_env_script = let
    homebrew_mirror_env = { # Homebrew Mirror
      # NOTE: This is only useful when you run `brew install` manually! (not via nix-darwin)
      # TUNA mirror
      # HOMEBREW_API_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api";
      # HOMEBREW_BOTTLE_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles";
      # HOMEBREW_BREW_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git";
      # HOMEBREW_CORE_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git";
      # HOMEBREW_PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";

      # NJU mirror
      HOMEBREW_API_DOMAIN = "https://mirror.nju.edu.cn/homebrew-bottles/api";
      HOMEBREW_BOTTLE_DOMAIN = "https://mirror.nju.edu.cn/homebrew-bottles";
      HOMEBREW_BREW_GIT_REMOTE = "https://mirror.nju.edu.cn/git/homebrew/brew.git";
      HOMEBREW_CORE_GIT_REMOTE = "https://mirror.nju.edu.cn/git/homebrew/homebrew-core.git";
      HOMEBREW_PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";
    };
  in lib.attrsets.foldlAttrs (acc: name: value: acc + "\nexport ${name}=${value}") "" homebrew_mirror_env;
in {
  system.primaryUser = myvars.username;
  ## START networking.nix
  networking.knownNetworkServices = ["Wi-Fi"];
  networking.dns = [ # sing-box requires a non-local address to hijack DNS
    "223.5.5.5"
    # "2400:3200::1"
    "8.8.8.8"
  ];
  ## END networking.nix
  ## START ssh.nix
  # Disable password authentication for SSH
  environment.etc."ssh/sshd_config.d/200-disable-password-auth.conf".text = ''
    PasswordAuthentication no
    KbdInteractiveAuthentication no
  '';
  ## END ssh.nix
  ## START security.nix
  security.pam.services.sudo_local.touchIdAuth = true; # Add ability to used TouchID for sudo authentication
  ## END security.nix
  ## START packages.nix
  environment.systemPackages = with pkgs; [
    m-cli # Swiss Army Knife for macOS, https://github.com/rgcr/m-cli
    mas # Mac App Store command line interface

    raycast # (HotKey: alt/option + space)search, calculate and run scripts(with many plugins)
    stats # Beautiful system status monitor in menu bar
    betterdisplay # Unlock display settings
  ];
  ## START packages.nix
  ## START terminal.nix
  environment.variables.TERMINFO_DIRS = (map (path: path + "/share/terminfo") config.environment.profiles)
    ++ ["/usr/share/terminfo"];
  ## END terminal.nix
  ## START shell.nix
  programs.zsh.enableSyntaxHighlighting = true;
  environment.shells = [pkgs.zsh];
  ## END shell.nix
  ## BEGIN brew.nix
  system.activationScripts.homebrew.text = lib.mkBefore ''
    echo >&2 '# DEBUG:${homebrew_env_script}'
    ${homebrew_env_script}
  '';
  # homebrew need to be installed manually, see https://github.com/nix-darwin/nix-darwin/blob/44a7d0e687a87b73facfe94fba78d323a6686a90/modules/homebrew.nix#L541
  environment.etc.zprofile.text = lib.mkAfter ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
  homebrew = { # homebrew need to be installed manually, see https://brew.sh
    enable = true; # disable homebrew for fast deploy

    onActivation = {
      autoUpdate = true; # Fetch the newest stable branch of Homebrew's git repo
      upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
      # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
      cleanup = "zap";
    };
    # Applications to install from Mac App Store using mas. You need to install all these Apps manually first so that
    # your apple account have records for them. otherwise Apple Store will refuse to install them. For details, see
    # https://github.com/mas-cli/mas
    masApps = {
      "Microsoft Excel" = 462058435;
      "Microsoft Outlook" = 985367838;
      "Microsoft PowerPoint" = 462062816;
      "Microsoft Word" = 462054704;
      OneDrive = 823766827;
      QQ = 451108668;
      WeChat = 836500024;

      # "GeoGebra Calculator Suite" = 1504416652; # Managed by home-manager
      # LocalSend = 1661733229; # Managed by home-manager
      # Telegram = 747648890; # Managed by home-manager
      # sing-box = 6673731168; # Older than sfm in brew cask
    };
    taps = [
      "hashicorp/tap"
      "gcenx/wine" # homebrew-wine - game-porting-toolkit & wine-crossover
    ];
    brews = [ # formulae, 'brew install'
      # "llvm" "lld" "cmake" "ninja" # Poorly with stdlib
    ];
    casks = [ # 'brew install --cask'
      "blender" # 3D modeling, currently in nixpkg it's marked as broken on darwin
      "keepassxc" # gpgme is marked as broken, use casks temporally
      # "sfm" # Standalone client for sing-box, it lacks some features compares to its cli version
      # "clash-verge-rev"
      "jordanbaird-ice" # Powerful menu bar manager
      "tor-browser"

      # Misc
      # "tencent-lemon" # macOS cleaner
      "neteasemusic" # music
      # "mihomo-party" # transparent proxy tool
      "obs"
      # "ibkr"
      "trader-workstation"

      # Development
      # "miniforge" # Miniconda's community-driven distribution

      # Setup macfuse: https://github.com/macfuse/macfuse/wiki/Getting-Started
      "macfuse" # for rclone to mount a fuse filesystem

      # "game-porting-toolkit"
      # "gcenx/wine/wine-crossover" # Conflicts with game-porting-toolkit
      # "crossover"
      "steam"
      "mythic" # EPIC game launcher

      ## Creative
      # "sonic-pi" # Music programming
      # "reaper" # Audio editor, managed by home-manager
      "inkscape" # Vector graphics, currently broken in nixpkgs
      "gimp" # As of 11/6/2025, currently not supported on nixpkgs

      # "windows-app" # Formerly microsoft-remote-desktop, I use remmina instead
    ];
  };
  ## END brew.nix
  ## START users.nix
  users.users.${myvars.username} = {
    home = "/Users/${myvars.username}"; # home-manager needs it
    # nix-darwin doesn't have `users.defaultUserShell`. If this don't work, try
    # chsh -s /run/current-system/sw/bin/zsh
    shell = pkgs.zsh;
  };
  ## END users.nix
}
