{lib, pkgs, myvars, mylib, ...}: {
  system.stateVersion = lib.mkDefault (
    if pkgs.stdenv.isDarwin then myvars.darwin_state_version else myvars.nixos_state_version);
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
  ## START i18n.nix
  # NOTE: On macOS, Please set [Set time zone automatically using your current location] to false in [System Settings]
  time.timeZone = lib.mkDefault "Asia/Hong_Kong";
  ## END i18n.nix
  ## START ssh.nix
  services.openssh.enable = lib.mkDefault true;
  programs.ssh = {
    extraConfig = ''
    Compression yes
    ControlMaster auto
    ControlPath ~/.ssh/master-%r@%n:%p
    ControlPersist 30m
    ServerAliveInterval 30
    ServerAliveCountMax 5
    ''
      + myvars.networking.ssh.extra_config;
    knownHosts = myvars.networking.ssh.known_hosts;
  };
  ## END ssh.nix
  ## START shell.nix
  programs.zsh = {
    enable = lib.mkDefault true; # On darwin, this creates /etc/zshrc that loads the nix-darwin environment. Which is
    # required if you want to use darwin's default shell - zsh
    interactiveShellInit = ''
    # START Zsh Shell Coloring
    # Reset
    Color_Off=$'\e[m'       # Text Reset

    # Regular Colors
    Black=$'\e[0;30m'       # Black
    Red=$'\e[0;31m'         # Red
    Green=$'\e[0;32m'       # Green
    Yellow=$'\e[0;33m'      # Yellow
    Blue=$'\e[0;34m'        # Blue
    Purple=$'\e[0;35m'      # Purple
    Cyan=$'\e[0;36m'        # Cyan
    White=$'\e[0;37m'       # White

    # Bold
    BBlack=$'\e[1;30m'      # Black
    BRed=$'\e[1;31m'        # Red
    BGreen=$'\e[1;32m'      # Green
    BYellow=$'\e[1;33m'     # Yellow
    BBlue=$'\e[1;34m'       # Blue
    BPurple=$'\e[1;35m'     # Purple
    BCyan=$'\e[1;36m'       # Cyan
    BWhite=$'\e[1;37m'      # White

    # Underline
    UBlack=$'\e[4;30m'      # Black
    URed=$'\e[4;31m'        # Red
    UGreen=$'\e[4;32m'      # Green
    UYellow=$'\e[4;33m'     # Yellow
    UBlue=$'\e[4;34m'       # Blue
    UPurple=$'\e[4;35m'     # Purple
    UCyan=$'\e[4;36m'       # Cyan
    UWhite=$'\e[4;37m'      # White

    # Background
    On_Black=$'\e[40m'      # Black
    On_Red=$'\e[41m'        # Red
    On_Green=$'\e[42m'      # Green
    On_Yellow=$'\e[43m'     # Yellow
    On_Blue=$'\e[44m'       # Blue
    On_Purple=$'\e[45m'     # Purple
    On_Cyan=$'\e[46m'       # Cyan
    On_White=$'\e[47m'      # White

    # High Intensity
    IBlack=$'\e[0;90m'      # Black
    IRed=$'\e[0;91m'        # Red
    IGreen=$'\e[0;92m'      # Green
    IYellow=$'\e[0;93m'     # Yellow
    IBlue=$'\e[0;94m'       # Blue
    IPurple=$'\e[0;95m'     # Purple
    ICyan=$'\e[0;96m'       # Cyan
    IWhite=$'\e[0;97m'      # White

    # Bold High Intensity
    BIBlack=$'\e[1;90m'     # Black
    BIRed=$'\e[1;91m'       # Red
    BIGreen=$'\e[1;92m'     # Green
    BIYellow=$'\e[1;93m'    # Yellow
    BIBlue=$'\e[1;94m'      # Blue
    BIPurple=$'\e[1;95m'    # Purple
    BICyan=$'\e[1;96m'      # Cyan
    BIWhite=$'\e[1;97m'     # White

    # High Intensity backgrounds
    On_IBlack=$'\e[0;100m'  # Black
    On_IRed=$'\e[0;101m'    # Red
    On_IGreen=$'\e[0;102m'  # Green
    On_IYellow=$'\e[0;103m' # Yellow
    On_IBlue=$'\e[0;104m'   # Blue
    On_IPurple=$'\e[10;95m' # Purple
    On_ICyan=$'\e[0;106m'   # Cyan
    On_IWhite=$'\e[0;107m'  # White
    # END Zsh Shell Coloring
    '';
    promptInit = ''
    autoload -U promptinit && promptinit; setopt PROMPT_SUBST
    PS1='[%{$BRed%}%n%{$Color_Off%}@%{$BBlue%}%m%{$Color_Off%} %{$BBlue%}%3~%{$Color_Off%} %{$BCyan%}%{$Color_Off%}]%{$BGreen%}%(#.#.$)%{$Color_Off%} '
    ''; # Fallback prompt if starship doesn't work
  };
  ## ENd shell.nix
  ## START users.nix
  users.users.${myvars.username} = {
    description = lib.mkDefault myvars.userfullname;
    openssh.authorizedKeys.keys = lib.mkDefault myvars.ssh_authorized_keys;
  };
  ## END users.nix
  ## START network.nix
  services.tailscale.enable = lib.mkDefault true; # Start-up: `tailscale up --accept-routes`
  services.sing-box.enable = lib.mkDefault true;
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
}
