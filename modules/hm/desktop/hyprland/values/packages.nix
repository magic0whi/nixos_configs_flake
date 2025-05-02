{pkgs, lib, config, ...}: with lib; {
  home.packages = with pkgs; [
    sound-theme-freedesktop
    swaybg # the wallpaper
    swaylock # locking the screen
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
  services.mako = {
    enable = true; # mako is trigged by dbus
    maxHistory = 100;
    padding = "5";
    borderRadius = 8;
    maxIconSize = 48;
    defaultTimeout = 5000;
    layer = "overlay";
    backgroundColor = "#1e1e2e";
    textColor = "#d9e0ee";
    borderColor = "#313244";
    progressColor = "over #89b4fa";
    extraConfig = ''
      on-button-middle=none
      on-button-right=dismiss-all
      on-notify=exec mpv ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/message.oga

      [urgency=low]
      border-color=#313244
      default-timeout=2000

      [urgency=normal]
      border-color=#313244

      [urgency=high]
      border-color=#f38ba8
      text-color=#f38ba8
      default-timeout=0

      [category=mpd]
      border-color=#f9e2af
      default-timeout=2000
      group-by=category
    '';
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
