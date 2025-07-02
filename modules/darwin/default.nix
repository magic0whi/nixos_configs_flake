{mylib, myvars, pkgs, config, lib, ...}: with lib; let
  # Homebrew Mirror
  # NOTE: is only useful when you run `brew install` manually! (not via nix-darwin)
  homebrew_mirror_env = {
    # tuna mirror
    # HOMEBREW_API_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api";
    # HOMEBREW_BOTTLE_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles";
    # HOMEBREW_BREW_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git";
    # HOMEBREW_CORE_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git";
    # HOMEBREW_PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";

    # nju mirror
    HOMEBREW_API_DOMAIN = "https://mirror.nju.edu.cn/homebrew-bottles/api";
    HOMEBREW_BOTTLE_DOMAIN = "https://mirror.nju.edu.cn/homebrew-bottles";
    HOMEBREW_BREW_GIT_REMOTE = "https://mirror.nju.edu.cn/git/homebrew/brew.git";
    HOMEBREW_CORE_GIT_REMOTE = "https://mirror.nju.edu.cn/git/homebrew/homebrew-core.git";
    HOMEBREW_PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";
  };
  homebrew_env_script =
    attrsets.foldlAttrs
    (acc: name: value: acc + "\nexport ${name}=${value}")
    ""
    homebrew_mirror_env;
in {
  imports = mylib.scan_path ./.;
  system.stateVersion = mkDefault 6;
  system.primaryUser = mkDefault myvars.username;
  security.pki.certificateFiles = [
    (mylib.relative_to_root "custom_files/proteus_ca.pem")
  ];
  # Disable password authentication for SSH
  environment.etc."ssh/sshd_config.d/200-disable-password-auth.conf".text = mkDefault ''
    PasswordAuthentication no
    KbdInteractiveAuthentication no
  '';
  services.openssh.enable = mkDefault true;
  services.tailscale.enable = mkDefault true; # Usage: https://github.com/tailscale/tailscale/wiki/Tailscaled-on-macOS#run-the-tailscaled-daemon
  services.sing-box.enable = mkDefault true; # Current DNS hijack doesn't work
  # 1. 'sudo tailscaled install-system-daemon'
  # 2. `tailscale up --accept-routes`
  security.pam.services.sudo_local.touchIdAuth = true; # Add ability to used TouchID for sudo authentication
  nixpkgs.config.allowUnfree = mkDefault true; # Allow chrome, vscode to install
  nix.package = mkDefault pkgs.nixVersions.latest; # Use latest nix, default is pkgs.nix
  nix.gc = {
    automatic = mkDefault true;
    options = mkDefault "--delete-older-than 7d";
  };
  nix.channel.enable = mkDefault false; # remove nix-channel related tools & configs, use flakes instead.
  # Manual optimise storage: nix-store --optimise
  nix.optimise.automatic = mkDefault true; # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings = {
    # enable flakes globally
    experimental-features = mkDefault ["nix-command" "flakes"];

    # given the users in this list the right to specify additional substituters via:
    #    1. `nixConfig.substituers` in `flake.nix`
    #    2. command line args `--options substituers http://xxx`
    trusted-users = mkDefault [myvars.username];

    # substituers that will be considered before the official ones(https://cache.nixos.org)
    substituters = mkDefault [
      # cache mirror located in China
      # status: https://mirrors.ustc.edu.cn/status/
      # "https://mirrors.ustc.edu.cn/nix-channels/store"
      # status: https://mirror.sjtu.edu.cn/
      # "https://mirror.sjtu.edu.cn/nix-channels/store"
      # others
      "https://mirrors.sustech.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"

      "https://nix-community.cachix.org"
      # "https://ryan4yin.cachix.org" # my own cache server, currently not used.
      "https://colmena.cachix.org/"
    ];

    trusted-public-keys = mkDefault [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      # "ryan4yin.cachix.org-1:Gbk27ZU5AYpGS9i3ssoLlwdvMIh0NxG0w8it/cv9kbU="
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
    ];
    builders-use-substitutes = mkDefault true;
    sandbox = mkDefault true;
  };
  environment.systemPackages= with pkgs; [
    iproute2mac
    git
    git-lfs
    git-trim
    tree
    helix
    findutils
    gnugrep
    gnutar
    curl
    aria2
    rsync
    doggo

    m-cli # Swiss Army Knife for macOS, https://github.com/rgcr/m-cli
    mas # Mac App Store command line interface

    raycast # (HotKey: alt/option + space)search, calculate and run scripts(with many plugins)
    stats # beautiful system status monitor in menu bar
  ];
  environment.variables = {
    TERMINFO_DIRS = (map (path: path + "/share/terminfo") config.environment.profiles) ++ ["/usr/share/terminfo"];
  };
  system.activationScripts.homebrew.text = mkBefore ''
    echo >&2 '${homebrew_env_script}'
    ${homebrew_env_script}
  '';
  programs.zsh = {
    enable = mkDefault true; # Create /etc/zshrc that loads the nix-darwin environment. This is required if you want to use darwin's default shell - zsh
    enableSyntaxHighlighting = mkDefault true;
    interactiveShellInit = ''
    # START Zsh Shell Coloring
    # Reset
    Color_Off=$'\e[m'       # Text Reset

    # Regular Colors
    Black=$'\e[0;30m'        # Black
    Red=$'\e[0;31m'          # Red
    Green=$'\e[0;32m'        # Green
    Yellow=$'\e[0;33m'       # Yellow
    Blue=$'\e[0;34m'         # Blue
    Purple=$'\e[0;35m'       # Purple
    Cyan=$'\e[0;36m'         # Cyan
    White=$'\e[0;37m'        # White

    # Bold
    BBlack=$'\e[1;30m'       # Black
    BRed=$'\e[1;31m'         # Red
    BGreen=$'\e[1;32m'       # Green
    BYellow=$'\e[1;33m'      # Yellow
    BBlue=$'\e[1;34m'        # Blue
    BPurple=$'\e[1;35m'      # Purple
    BCyan=$'\e[1;36m'        # Cyan
    BWhite=$'\e[1;37m'       # White

    # Underline
    UBlack=$'\e[4;30m'       # Black
    URed=$'\e[4;31m'         # Red
    UGreen=$'\e[4;32m'       # Green
    UYellow=$'\e[4;33m'      # Yellow
    UBlue=$'\e[4;34m'        # Blue
    UPurple=$'\e[4;35m'      # Purple
    UCyan=$'\e[4;36m'        # Cyan
    UWhite=$'\e[4;37m'       # White

    # Background
    On_Black=$'\e[40m'       # Black
    On_Red=$'\e[41m'         # Red
    On_Green=$'\e[42m'       # Green
    On_Yellow=$'\e[43m'      # Yellow
    On_Blue=$'\e[44m'        # Blue
    On_Purple=$'\e[45m'      # Purple
    On_Cyan=$'\e[46m'        # Cyan
    On_White=$'\e[47m'       # White

    # High Intensity
    IBlack=$'\e[0;90m'       # Black
    IRed=$'\e[0;91m'         # Red
    IGreen=$'\e[0;92m'       # Green
    IYellow=$'\e[0;93m'      # Yellow
    IBlue=$'\e[0;94m'        # Blue
    IPurple=$'\e[0;95m'      # Purple
    ICyan=$'\e[0;96m'        # Cyan
    IWhite=$'\e[0;97m'       # White

    # Bold High Intensity
    BIBlack=$'\e[1;90m'      # Black
    BIRed=$'\e[1;91m'        # Red
    BIGreen=$'\e[1;92m'      # Green
    BIYellow=$'\e[1;93m'     # Yellow
    BIBlue=$'\e[1;94m'       # Blue
    BIPurple=$'\e[1;95m'     # Purple
    BICyan=$'\e[1;96m'       # Cyan
    BIWhite=$'\e[1;97m'      # White

    # High Intensity backgrounds
    On_IBlack=$'\e[0;100m'   # Black
    On_IRed=$'\e[0;101m'     # Red
    On_IGreen=$'\e[0;102m'   # Green
    On_IYellow=$'\e[0;103m'  # Yellow
    On_IBlue=$'\e[0;104m'    # Blue
    On_IPurple=$'\e[10;95m'  # Purple
    On_ICyan=$'\e[0;106m'    # Cyan
    On_IWhite=$'\e[0;107m'   # White
    # END Zsh Shell Coloring
    '';
    promptInit = ''
      autoload -U promptinit && promptinit; setopt PROMPT_SUBST
      PS1='[%{$BRed%}%n%{$Color_Off%}@%{$BBlue%}%m%{$Color_Off%} %{$BBlue%}%3~%{$Color_Off%} %{$BCyan%}%{$Color_Off%}]%{$BGreen%}%(#.#.$)%{$Color_Off%} '
    ''; # Fallback prompt if starship doesn't work
  };
  environment.shells = [pkgs.zsh];
  ## BEGIN brew.nix
  # homebrew need to be installed manually, see https://github.com/nix-darwin/nix-darwin/blob/44a7d0e687a87b73facfe94fba78d323a6686a90/modules/homebrew.nix#L541
  environment.etc.zprofile.text = mkAfter ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
  homebrew = { # homebrew need to be installed manually, see https://brew.sh
    enable = mkDefault true; # disable homebrew for fast deploy

    onActivation = {
      autoUpdate = mkDefault true; # Fetch the newest stable branch of Homebrew's git repo
      upgrade = mkDefault true; # Upgrade outdated casks, formulae, and App Store apps
      # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
      cleanup = mkDefault "zap";
    };

    masApps = { # Applications to install from Mac App Store using mas. You need to install all these Apps manually first so that your apple account have records for them. otherwise Apple Store will refuse to install them. For details, see https://github.com/mas-cli/mas
      "GeoGebra Calculator Suite" = 1504416652;
      LocalSend = 1661733229;
      "Microsoft Excel" = 462058435;
      "Microsoft Outlook" = 985367838;
      "Microsoft PowerPoint" = 462062816;
      "Microsoft Word" = 462054704;
      OneDrive = 823766827;
      QQ = 451108668;
      # "sing-box" = 6673731168; # Older than sfm in brew cask
      Telegram = 747648890;
      WeChat = 836500024;
    };

    taps = [
      "hashicorp/tap"
      "gcenx/wine" # homebrew-wine - game-porting-toolkit & wine-crossover
    ];
    brews = [ # 'brew install'
    ];
    casks = [ # 'brew install --cask'
      "keepassxc" # gpgme is marked as broken, use casks temporally
      "sfm" # Standalone client for sing-box, it lacks some features compares to its cli version
      "clash-verge-rev"
      "jordanbaird-ice" # Powerful menu bar manager

      # "discord" # update too frequently, use the web version instead
      "windows-app" # Formerly microsoft-remote-desktop

      # Misc
      # "reaper"  # audio editor
      "sonic-pi" # music programming
      "tencent-lemon" # macOS cleaner
      "neteasemusic" # music
      "mihomo-party" # transparent proxy tool

      # Development
      # "miniforge" # Miniconda's community-driven distribution

      # Setup macfuse: https://github.com/macfuse/macfuse/wiki/Getting-Started
      "macfuse" # for rclone to mount a fuse filesystem

      # "game-porting-toolkit"
      "gcenx/wine/wine-crossover" # Conflicts with game-porting-toolkit
      "crossover"
      "steam"
      "mythic"
      "obs"
      "inkscape"
    ];
  };
  ## END brew.nix
  ## START users.nix
  users.users.${myvars.username} = {
    description = mkDefault myvars.userfullname;
    home = mkDefault "/Users/${myvars.username}"; # home-manager needs it
    openssh.authorizedKeys.keys = mkDefault myvars.ssh_authorized_keys;
  };
  ## END users.nix
  ## START fonts.nix
  fonts.packages = with pkgs; [
    inter-nerdfont
    nerd-fonts.symbols-only # symbols icon only
    nerd-fonts.iosevka
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
  ];
  ## END fonts.nix
}
