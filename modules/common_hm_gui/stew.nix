{pkgs, lib, ...}: {
  home.packages = with pkgs; [
    localsend # Alternative to AirDrop
    telegram-desktop # Instant messaging
    # discord # Update too frequently, use the web version instead

    ## Remote Desktop (RDP protocol)
    remmina
    freerdp # Required by remmina
    # moonlight # Remote desktop client

    ## Games
    # modrinth-app
    # prismlauncher # A free, open source launcher for Minecraft
    # winetricks # A script to install DLLs needed to work around problems in Wine

    ## Creative
    geogebra6 # Dynamic mathematics software with graphics, algebra and spreadsheets
    (if pkgs.stdenv.isLinux
    then (anki-bin.overrideAttrs (_: prev: { # Add env 'QT_IM_MODULE=fcitx' to anki.desktop
      buildCommand = lib.strings.concatLines [
        prev.buildCommand # TIPS: `builtins.trace test.buildCommand {}` is useful in debugging
        ''unpacked=$(grep -Po '(?<=cp -R )\/nix\/store\/\S+(?=\/share\/applications)' <<< '${prev.buildCommand}')''
        ''perm_bak=$(stat -c '%a' $out/share/applications/anki.desktop)''
        ''chmod 644 $out/share/applications/anki.desktop''
        ''sed 's/^Exec=\(anki\)/Exec=env QT_IM_MODULE=fcitx \1/' $unpacked/share/applications/anki.desktop > $out/share/applications/anki.desktop''
        ''chmod $perm_bak $out/share/applications/anki.desktop''
      ];
    }))
    else anki-bin)
    code-cursor # An AI code editor
    blender # 3D modeling
    inkscape # Vector graphics
    musescore # Music notation
    # reaper # Audio production

    # Dev-tools
    # insomnia # REST client
    # wireshark # Network analyzer
  ];
  ## START browsers.nix
  programs.firefox.enable = true;
  programs.google-chrome = { # https://github.com/nix-community/home-manager/blob/master/modules/programs/chromium.nix
    enable = true;
    # https://wiki.archlinux.org/title/Chromium#Native_Wayland_support
    commandLineArgs = lib.optionals pkgs.stdenv.isLinux [
      "--ozone-platform-hint=auto"
      "--enable-wayland-ime" # Make it use text-input-v1, which works for kwin 5.27 and weston
      # "--enable-features=Vulkan" # Enable hardware acceleration - vulkan api
    ];
  };
  ## END browsers.nix
  ## START vscode.nix
  programs.vscode = {
    enable = true;
    # Use gnome-keyring as password store
    package = if pkgs.stdenv.isLinux
    then pkgs.vscode.override {commandLineArgs = ["--password-store=gnome"];}
    else pkgs.vscode;
    # Let vscode sync and update its configuration & extensions across devices, using github account
    profiles.default.userSettings = {};
  };
  programs.joplin-desktop.enable = true; # Note taking app, https://joplinapp.org/help/
  ## END vscode.nix
}
