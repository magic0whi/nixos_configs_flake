{pkgs, lib, ...}: {
  home.packages = [(pkgs.anki-bin.overrideAttrs (_: prev: {
    # TIPS: 'builtins.trace <string> {}' is useful for debug
    buildCommand = lib.strings.concatLines [ # Add environment 'QT_IM_MODULE=fcitx' for anki
      prev.buildCommand
      ''unpacked=$(grep -Po '(?<=cp -R )\/nix\/store\/\S+(?=\/share\/applications)' <<< '${prev.buildCommand}')''
      ''perm_bak=$(stat -c '%a' $out/share/applications/anki.desktop)''
      ''chmod 644 $out/share/applications/anki.desktop''
      ''sed 's/^Exec=\(anki\)/Exec=env QT_IM_MODULE=fcitx \1/' $unpacked/share/applications/anki.desktop > $out/share/applications/anki.desktop''
      ''chmod $perm_bak $out/share/applications/anki.desktop''
    ];
  }))];
  services.psd.enable = true;
  programs = {
    firefox.enable = true;
    google-chrome = { # https://github.com/nix-community/home-manager/blob/master/modules/programs/chromium.nix
      enable = true;
      commandLineArgs = [ # https://wiki.archlinux.org/title/Chromium#Native_Wayland_support
        "--ozone-platform-hint=auto"
        "--enable-wayland-ime" # Make it use text-input-v1, which works for kwin 5.27 and weston
        # "--enable-features=Vulkan" # Enable hardware acceleration - vulkan api
      ];
    };
    vscode = {
      enable = false;
      # let vscode sync and update its configuration & extensions across devices, using github account.
      package = (pkgs.vscode.override {
        isInsiders = true;
        commandLineArgs = [ # https://wiki.archlinux.org/title/Wayland#Electron
          "--ozone-platform-hint=auto"
          "--ozone-platform=wayland"
          "--enable-wayland-ime" # make it use text-input-v1, which works for kwin 5.27 and weston

          # TODO: fix https://github.com/microsoft/vscode/issues/187436
          # still not works...
          "--password-store=gnome" # use gnome-keyring as password store
        ];
      }).overrideAttrs (oldAttrs: { # Use VSCode Insiders to fix crash: https://github.com/NixOS/nixpkgs/issues/246509
        src = builtins.fetchTarball {
          url = "https://update.code.visualstudio.com/latest/linux-x64/insider";
          sha256 = "1mx36rn758wl5mcl3ryd5jqf8ls5an26j0i0g95ksb3hm2606k1m";
        };
        version = "latest";
      });
      profiles.default.userSettings = {};
    };
  };
}
