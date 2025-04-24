{pkgs, ...}: {
  programs = {
    firefox.enable = true;
    google-chrome = { # https://github.com/nix-community/home-manager/blob/master/modules/programs/chromium.nix
      enable = true;
      commandLineArgs = [ # https://wiki.archlinux.org/title/Chromium#Native_Wayland_support
        "--ozone-platform-hint=auto"
        "--ozone-platform=wayland"
        # make it use GTK_IM_MODULE if it runs with Gtk4, so fcitx5 can work with it.
        # (only supported by chromium/chrome at this time, not electron)
        "--gtk-version=4"
        # make it use text-input-v1, which works for kwin 5.27 and weston
        "--enable-wayland-ime"

        # enable hardware acceleration - vulkan api
        # "--enable-features=Vulkan"
      ];
    };
    vscode = {
      enable = true;
      # let vscode sync and update its configuration & extensions across devices, using github account.
      package = (pkgs.vscode.override {
        isInsiders = true;
        commandLineArgs = [ # https://wiki.archlinux.org/title/Wayland#Electron
          "--ozone-platform-hint=auto"
          "--ozone-platform=wayland"
          # make it use GTK_IM_MODULE if it runs with Gtk4, so fcitx5 can work with it.
          # (only supported by chromium/chrome at this time, not electron)
          "--gtk-version=4"
          # make it use text-input-v1, which works for kwin 5.27 and weston
          "--enable-wayland-ime"

          # TODO: fix https://github.com/microsoft/vscode/issues/187436
          # still not works...
          "--password-store=gnome" # use gnome-keyring as password store
        ];
      }).overrideAttrs (oldAttrs: { # Use VSCode Insiders to fix crash: https://github.com/NixOS/nixpkgs/issues/246509
        src = builtins.fetchTarball {
          url = "https://update.code.visualstudio.com/latest/linux-x64/insider";
          sha256 = "1x3bakpn6h6nb2gwn698bwkgw8w4cqcxgq098rynrpphpy503sl8";
        };
        version = "latest";
      });
      profiles.default.userSettings = {};
    };
  };
}
