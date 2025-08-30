{pkgs, lib, config, ...}: {
  home.packages = with pkgs; [
    sound-theme-freedesktop
    swaybg # the wallpaper
    wlogout # logout menu
    wl-clipboard # copying and pasting
    hyprpicker # color picker

    hyprshot # screenshot
    grim # taking screenshots
    slurp # selecting a region to screenshot
    wf-recorder # screen recording

    yad # a fork of zenity, for creating dialogs

    # audio
    alsa-utils # provides amixer/alsamixer/...
    mpc-cli # command-line mpd client
    ncmpcpp # a mpd client with a UI

    ffmpeg-full

    # images
    # viu # Terminal image viewer with native support for iTerm and Kitty
    imagemagick # Provides 'convert'
    graphviz
  ];
  services.mako = let
    cuppuccin-mocha = { # TODO: https://github.com/catppuccin/nix/blob/main/modules/home-manager/mako.nix
      base = "#1e1e2e";
      blue = "#89b4fa";
      red = "#f38ba8";
      surface0 = "#313244";
      text = "#cdd6f4";
      yellow = "#f9e2af";
    };
  in with cuppuccin-mocha; {
    enable = true; # mako is trigged by dbus
    settings = {
      max-history = 100;
      padding = 5;
      border-radius = 8;
      max-icon-size = 48;
      default-timeout = 5000;
      layer = "overlay";
      background-color = base;
      text-color = text;
      border-color = surface0;
      progress-color = "over ${blue}";
      on-button-middle = "none";
      on-button-right = "dismiss-all";
      on-notify = "exec mpv ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/message.oga";
      "urgency=low" = {
        border-color = surface0;
        default-timeout = 2000;
      };
      "urgency=normal" = {
        border-color = surface0;
      };
      "urgency=high" = {
        border-color = red;
        text-color = red;
        default-timeout = "0";
      };
      "category=mpd" = {
        border-color = yellow;
        default-timeout = 2000;
        group-by = "category";
      };
    };
  };
  services.mpd = {
    enable = true;
    dbFile = "${config.xdg.dataHome}/mpd/database";
    extraConfig = ''
      auto_update "yes"
      audio_output {
        type "pipewire"
        name "PipeWire Sound Server"
      }
    '';
  };
}
