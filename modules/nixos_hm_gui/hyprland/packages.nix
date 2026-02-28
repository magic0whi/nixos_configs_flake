{pkgs, config, myvars, ...}: {
  home.packages = with pkgs; [
    brightnessctl
    sound-theme-freedesktop
    wlogout # logout menu
    wl-clipboard # copying and pasting
    hyprpicker # color picker
    hyprshot # screenshot
    wf-recorder # screen recording

    yad # a fork of zenity, for creating dialogs

    # audio
    alsa-utils # provides amixer/alsamixer/...
    mpc # command-line mpd client
    ncmpcpp # a mpd client with a UI

    ffmpeg-full

    # images
    # viu # Terminal image viewer with native support for iTerm and Kitty
    imagemagick # Provides 'convert'
    graphviz
  ];
  services.mako = {
    enable = true; # mako is trigged by dbus
    settings = {
      max-history = 100;
      padding = 5;
      border-radius = 8;
      max-icon-size = 48;
      default-timeout = 5000;
      layer = "overlay";
      on-button-middle = "none";
      on-button-right = "dismiss-all";
      on-notify =
        "exec mpv --keep-open=no ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/message.oga";
      "urgency=low".default-timeout = 2000;
      "urgency=high".default-timeout = "0";
      "category=mpd" = {
        default-timeout = 2000;
        group-by = "category";
      };
    };
  };
  age.secrets."mpd_auth.conf" = {file = "${myvars.secrets_dir}/mpd_auth.conf.age"; mode = "0400";};
  services.mpd = {
    enable = true;
    network.startWhenNeeded = true;
    dbFile = "${config.xdg.dataHome}/mpd/database";
    extraConfig = ''
      auto_update "yes"
      audio_output {
        type "pipewire"
        name "PipeWire Sound Server"
      }
      # Lock down unauthenticated access. By default, all clients are
      # unauthenticated and have a full set of permissions.
      default_permissions ""
      # MPD is badly support for NixOS
      include "/run/user/1000/agenix/mpd_auth.conf"
    '';
  };
}
