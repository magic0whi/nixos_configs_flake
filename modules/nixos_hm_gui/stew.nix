{pkgs, ...}: {
  home.packages = with pkgs; [
    blender
    telegram-desktop # Instant messaging
    # foliate # e-book viewer(.epub/.mobi/...),do not support .pdf

    ## Custom Hardened Packages
    # nixpaks.qq
    # nixpaks.qq-desktop-item
    # nixpaks.wechat-uos
    # nixpaks.wechat-uos-desktop-item
    # wechat-uos

    ## Games
    # nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.osu-laser-bin
    # gamescope # SteamOS session compositing window manager

    ## Creative
    inkscape # Vector graphics
    gimp3 # Image editing, I prefer using figma in browser instead of this one
    # krita # digital painting
    # sonic-pi # music programming
    # kicad # Consumes a lot of storage, as of 7/24/2025, it's broken on macOS
    kicad-small # 3D printing, eletrical engineering (without 3D models)

    ## 2D game design
    # ldtk # A modern, versatile 2D level editor
    # aseprite # Animated sprite editor & pixel art tool

    # virt-viewer # VNC connect to VM, used by kubevirt

    # Audio control
    pavucontrol
    pulsemixer
    imv # simple image viewer

    # Video/audio tools
    # cava # for visualizing audio
    libva-utils
    # vdpauinfo
    vulkan-tools
    mesa-demos
    clinfo
  ];
  # This allows fontconfig to discover fonts and configurations installed through home.packages, but I manage fonts at
  # system-level, not user-level
  # fonts.fontconfig.enable = true;
  ## START gpg.nix
  services.gpg-agent.pinentry.package = pkgs.pinentry-qt; # GPG agent with pinentry-qt
  ## END gpg.nix
  ## START syncthing_tray.nix
  services.syncthing.tray.enable = true; # Only supports Linux platform
  ## END syncthing_tray.nix
  services.playerctld.enable = true; # playerctl
  ## START browsers.nix
  services.psd.enable = true;
  # Enable Ozone Wayland support in Chromium and Electron based applications
  home.sessionVariables.NIXOS_OZONE_WL = "1";
  ## END browsers.nix
  ## START obs-studio.nix
  programs.obs-studio = { # Live streaming
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      # screen capture
      wlrobs
      # obs-ndi
      obs-vaapi
      # obs-nvfbc
      obs-teleport
      # obs-hyperion
      droidcam-obs
      obs-vkcapture
      obs-gstreamer
      obs-3d-effect
      input-overlay
      obs-multi-rtmp
      obs-source-clone
      obs-shaderfilter
      obs-source-record
      obs-livesplit-one
      # looking-glass-obs
      obs-vintage-filter
      obs-command-source
      obs-move-transition
      obs-backgroundremoval
      # advanced-scene-switcher
      obs-pipewire-audio-capture
    ];
  };
  ## END obs-studio.nix
}
