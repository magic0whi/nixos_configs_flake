{mylib, lib, pkgs, ...}: with lib; {
  imports = mylib.scan_path ./.;
  fonts.fontconfig.enable = false; # This allows fontconfig to discover fonts and configurations installed through home.packages, but I manage fonts at system-level, not user-level
  ## START gpg.nix
  services.gpg-agent.pinentry.package = pkgs.pinentry-qt; # GPG agent with pinentry-qt
  ## END gpg.nix
  services.psd.enable = mkDefault true;
  ## START syncthing_tray.nix
  services.syncthing.tray.enable = true; # Only supports Linux platform
  ## END syncthing_tray.nix
  home.packages = with pkgs; [
    (anki-bin.overrideAttrs (_: prev: { # TIPS: 'builtins.trace <string> {}' is useful for debug
      buildCommand = lib.strings.concatLines [ # Add environment 'QT_IM_MODULE=fcitx' for anki
        prev.buildCommand
        ''unpacked=$(grep -Po '(?<=cp -R )\/nix\/store\/\S+(?=\/share\/applications)' <<< '${prev.buildCommand}')''
        ''perm_bak=$(stat -c '%a' $out/share/applications/anki.desktop)''
        ''chmod 644 $out/share/applications/anki.desktop''
        ''sed 's/^Exec=\(anki\)/Exec=env QT_IM_MODULE=fcitx \1/' $unpacked/share/applications/anki.desktop > $out/share/applications/anki.desktop''
        ''chmod $perm_bak $out/share/applications/anki.desktop''
      ];
    }))
    
    # GUI apps
    # foliate # e-book viewer(.epub/.mobi/...),do not support .pdf
    localsend
    telegram-desktop # instant messaging
    # discord # update too frequently, use the web version instead

    # remote desktop(rdp connect)
    # remmina
    # freerdp # required by remmina

    # my custom hardened packages
    # pkgs.nixpaks.qq
    # pkgs.nixpaks.qq-desktop-item

    # wechat-uos
    # pkgs.nixpaks.wechat-uos
    # pkgs.nixpaks.wechat-uos-desktop-item

    # Games
    # nix-gaming.packages.${pkgs.system}.osu-laser-bin
    # gamescope # SteamOS session compositing window manager
    # prismlauncher # A free, open source launcher for Minecraft
    # winetricks # A script to install DLLs needed to work around problems in Wine

    # Creative
    # blender # 3d modeling
    # gimp      # image editing, I prefer using figma in browser instead of this one
    inkscape # vector graphics
    # krita # digital painting
    # musescore # music notation
    # reaper # audio production
    # sonic-pi # music programming

    # 2d game design
    # ldtk # A modern, versatile 2D level editor
    # aseprite # Animated sprite editor & pixel art tool

    # this app consumes a lot of storage, so do not install it currently
    # kicad     # 3d printing, eletrical engineering

    # fpga
    # python312Packages.apycula # gowin fpga
    # yosys # fpga synthesis
    # nextpnr # fpga place and route
    # openfpgaloader # fpga programming

    # Dev-tools
    # mitmproxy # http/https proxy tool
    # insomnia # REST client
    # wireshark # network analyzer
    # virt-viewer # vnc connect to VM, used by kubevirt
  ];
  # programs.gh.enable = true; GitHub CLI tool
  programs = {
    ## START browsers.nix
    firefox.enable = mkDefault true;
    google-chrome = { # https://github.com/nix-community/home-manager/blob/master/modules/programs/chromium.nix
      enable = mkDefault true;
      commandLineArgs = [ # https://wiki.archlinux.org/title/Chromium#Native_Wayland_support
        "--ozone-platform-hint=auto"
        "--enable-wayland-ime" # Make it use text-input-v1, which works for kwin 5.27 and weston
        # "--enable-features=Vulkan" # Enable hardware acceleration - vulkan api
      ];
    };
    vscode = {
      enable = mkDefault true;
      # let vscode sync and update its configuration & extensions across devices, using github account.
      package = (pkgs.vscode.override {
        commandLineArgs = [ # https://wiki.archlinux.org/title/Wayland#Electron
          "--ozone-platform-hint=auto"
          "--ozone-platform=wayland"
          "--enable-wayland-ime" # make it use text-input-v1, which works for kwin 5.27 and weston

          # TODO: fix https://github.com/microsoft/vscode/issues/187436
          # still not works...
          "--password-store=gnome" # use gnome-keyring as password store
        ];
      });
      profiles.default.userSettings = {};
    };
    ## END browsers.nix
    # live streaming
    # obs-studio = {
    #   enable = true;
    #   plugins = with pkgs.obs-studio-plugins; [
    #     # screen capture
    #     wlrobs
    #     # obs-ndi
    #     obs-vaapi
    #     # obs-nvfbc
    #     obs-teleport
    #     # obs-hyperion
    #     droidcam-obs
    #     obs-vkcapture
    #     obs-gstreamer
    #     obs-3d-effect
    #     input-overlay
    #     obs-multi-rtmp
    #     obs-source-clone
    #     obs-shaderfilter
    #     obs-source-record
    #     obs-livesplit-one
    #     # looking-glass-obs
    #     obs-vintage-filter
    #     obs-command-source
    #     obs-move-transition
    #     obs-backgroundremoval
    #     # advanced-scene-switcher
    #     obs-pipewire-audio-capture
    #   ];
    # };
  };
}
