{mylib, pkgs, config, lib, ...}: let
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

  local_proxy_env = {
    # HTTP_PROXY = "http://127.0.0.1:7890";
    # HTTPS_PROXY = "http://127.0.0.1:7890";
  };

  homebrew_env_script =
    lib.attrsets.foldlAttrs
    (acc: name: value: acc + "\nexport ${name}=${value}")
    ""
    (homebrew_mirror_env // local_proxy_env);
in {
  imports = (mylib.scan_path ./.);
  environment.systemPackages= with pkgs; [
    helix
    git
    gnugrep
    gnutar

    utm # darwin only
  ];
  environment.variables = {
    TERMINFO_DIRS = (map (path: path + "/share/terminfo") config.environment.profiles) ++
      ["/usr/share/terminfo"];
  };
  system.activationScripts.homebrew.text = lib.mkBefore ''
    echo >&2 '${homebrew_env_script}'
    ${homebrew_env_script}
  '';
  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;
  environment.shells = [pkgs.zsh];
  # homebrew need to be installed manually, see https://brew.sh
  # https://github.com/LnL7/nix-darwin/blob/master/modules/homebrew.nix
  homebrew = {
    enable = true; # disable homebrew for fast deploy

    onActivation = {
      autoUpdate = true; # Fetch the newest stable branch of Homebrew's git repo
      upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
      # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
      cleanup = "zap";
    };

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    masApps = {
      # Xcode = 497799835;
      Wechat = 836500024;
      QQ = 451108668;
      # WeCom = 1189898970; # Wechat for Work
      TecentMeeting = 1484048379;
      QQMusic = 595615424;
    };

    taps = [
      "homebrew/services"

      "hashicorp/tap"
      "nikitabobko/tap" # aerospace - an i3-like tiling window manager for macOS
      "FelixKratz/formulae" # janky borders - highlight active window borders
    ];

    brews = [
      # `brew install`
      "wget" # download tool
      "curl" # no not install curl via nixpkgs, it's not working well on macOS!
      "aria2" # download tool
      "httpie" # http client
      "wireguard-tools" # wireguard

      # Usage:
      #  https://github.com/tailscale/tailscale/wiki/Tailscaled-on-macOS#run-the-tailscaled-daemon
      # 1. `sudo tailscaled install-system-daemon`
      # 2. `tailscale up --accept-routes`
      "tailscale" # tailscale

      # https://github.com/rgcr/m-cli
      "m-cli" #  Swiss Army Knife for macOS
      "proxychains-ng"

      # commands like `gsed` `gtar` are required by some tools
      "gnu-sed"
      "gnu-tar"

      # misc that nix do not have cache for.
      "git-trim"
      "terraform"
      "terraformer"
    ];

    # `brew install --cask`
    casks = [
      "squirrel" # input method for Chinese, rime-squirrel
      "firefox"
      "google-chrome"
      "visual-studio-code"
      "zed" # zed editor
      "cursor" # an AI code editor
      "aerospace" # an i3-like tiling window manager for macOS
      "ghostty" # terminal emulator

      # https://joplinapp.org/help/
      "joplin" # note taking app

      # IM & audio & remote desktop & meeting
      "telegram"
      # "discord" # update too frequently, use the web version instead
      "microsoft-remote-desktop"
      "moonlight" # remote desktop client
      "rustdesk" # meeting
      "zoom" # meeting

      # Misc
      # "shadowsocksx-ng" # proxy tool
      "iina" # video player
      "raycast" # (HotKey: alt/option + space)search, calculate and run scripts(with many plugins)
      "stats" # beautiful system status monitor in menu bar
      # "reaper"  # audio editor
      "sonic-pi" # music programming
      "tencent-lemon" # macOS cleaner
      "neteasemusic" # music
      "blender@lts" # 3D creation suite
      "mihomo-party" # transparent proxy tool

      # Development
      "mitmproxy" # HTTP/HTTPS traffic inspector
      "insomnia" # REST client
      "wireshark" # network analyzer
      # "jdk-mission-control" # Java Mission Control
      # "google-cloud-sdk" # Google Cloud SDK
      "miniforge" # Miniconda's community-driven distribution

      # Setup macfuse: https://github.com/macfuse/macfuse/wiki/Getting-Started
      "macfuse" # for rclone to mount a fuse filesystem
    ];
  };
}
