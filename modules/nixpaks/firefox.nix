# Refer:
# - Flatpak manifest's docs:
#   - https://docs.flatpak.org/en/latest/manifests.html
#   - https://docs.flatpak.org/en/latest/sandbox-permissions.html
# - Firefox's flatpak manifest: https://hg-edge.mozilla.org/mozilla-central/file/tip/browser/installer/linux/app/flatpak
{pkgs, mkNixPak, ...}: mkNixPak {
  config = {config, sloth, ...}: {
    app = {
      package = pkgs.firefox;
      binPath = "bin/firefox";
    };
    flatpak.appId = "org.mozilla.firefox";

    imports = [
      ./modules/gui-base.nix
      ./modules/network.nix
    ];

    # list all dbus services:
    #   ls -al /run/current-system/sw/share/dbus-1/services/
    #   ls -al /etc/profiles/per-user/${myvar.username}/share/dbus-1/services/
    dbus.policies = {
      "org.mozilla.firefox_beta.*" = "own"; # firefox beta
      "org.mpris.MediaPlayer2.firefox.*" = "own";
      "org.freedesktop.NetworkManager" = "talk";
      "org.freedesktop.ScreenSaver" = "talk";
      "org.freedesktop.FileManager1" = "talk";
    };

    bubblewrap = {
      # To trace all the home files Firefox accesses, you can use the following nushell command:
      #   just trace-access firefox
      # See the Justfile in the root of this repository for more information.
      bind.rw = [
        # given the read write permission to the following directories.
        # NOTE: sloth.mkdir is used to create the directory if it does not exist!
        (sloth.mkdir (sloth.concat' sloth.homeDir "/.mozilla"))
        (sloth.mkdir (sloth.concat' sloth.xdgCacheHome "/mozilla"))

        sloth.xdgDownloadDir
        # ================ for externsions ===============================
        # required by https://github.com/browserpass/browserpass-extension
        (sloth.concat' sloth.homeDir "/.local/share/password-store") # pass
      ];
      bind.ro = [
        "/sys/bus/pci" # To actually make Firefox run
        ["${config.app.package}/lib/firefox" "/app/etc/firefox"]
      ];

      sockets = {
        x11 = false;
        wayland = true;
        pipewire = true;
      };
      bind.dev = [
        "/dev/shm" # Shared Memory
      ];
      tmpfs = [
        "/tmp"
      ];
    };
  };
}
