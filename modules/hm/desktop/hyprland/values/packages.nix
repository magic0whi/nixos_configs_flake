{pkgs, lib, myvars, ...}: with lib; {
  home.packages = with pkgs; [
    swaybg # the wallpaper
    swaylock # locking the screen
    wlogout # logout menu
    wl-clipboard # copying and pasting
    hyprpicker # color picker

    hyprshot # screenshot
    grim # taking screenshots
    slurp # selecting a region to screenshot
    wf-recorder # screen recording

    mako # the notification daemon, the same as dunst

    yad # a fork of zenity, for creating dialogs

    # audio
    alsa-utils # provides amixer/alsamixer/...
    mpd # for playing system sounds
    mpc-cli # command-line mpd client
    ncmpcpp # a mpd client with a UI
  ];
  # xdg.configFile."waybar/catppuccin.css".source = "${myvars.catppuccin}/waybar/${myvars.catppuccin_variant}.css";
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = ''
/* Run 'waybar -l debug' to viewing the widget tree */
/* https://www.w3.org/TR/selectors-3 */
/* https://docs.gtk.org/gtk3/css-properties.html */
/* https://docs.gtk.org/gtk3/css-overview.html#colors */
/* Specificity
a = Number of ID selectors
b = number of class selectors
c = number of type selectors
*/
@define-color gruvbox-bg #282828;
@define-color gruvbox-fg #ebdbb2;
@define-color gruvbox-red #cc241d;
@define-color gruvbox-green #98971a;
@define-color gruvbox-yellow #d79921;
@define-color gruvbox-blue #458588;
@define-color gruvbox-purple #b16286;
@define-color gruvbox-gray #a89984;

window#waybar {
  background-color: transparent;
  font-family: Symbols Nerd Font, Iosevka Nerd Font Mono, sans-serif;
  font-size: 16px; /* TODO HIDPI */
}

tooltip {
  background: @gruvbox-bg;
  border: 2px solid @gruvbox-gray;
  font-size: 16px; /* TODO HIDPI */
}

tooltip label {
  color: @gruvbox-fg;
}

.module {
  margin-left: 2px; /* TODO HIDPI */
  margin-right: 2px; /* TODO HIDPI */
}

/* If workspaces is the leftmost module, omit left margin */
/* .modules-left>widget:first-child>#workspaces {
  margin-left: 0;
} */

/* If workspaces is the rightmost module, omit right margin */
/* .modules-right>widget:last-child>#workspaces {
  margin-right: 0;
} */

#backlight,
#battery,
#clock,
#cpu,
#idle_inhibitor,
#keyboard-state,
#memory,
#mpd,
#network,
#power-profiles-daemon,
#privacy,
#pulseaudio,
#submap,
#temperature,
#tray,
#window,
#workspaces {
  background-color: @gruvbox-bg;
  border-radius: 8px;
  color: @gruvbox-fg;
  padding: 0 5px; /* TODO HIDPI */
  transition-property: background-color;
  transition-duration: .5s;
}

#battery.charging,
#battery.plugged {
  color: @gruvbox-bg;
  background-color: @gruvbox-green;
}

#battery:hover,
#clock:hover,
#idle_inhibitor:hover,
#network:hover,
#pulseaudio:hover {
  background-color: @gruvbox-yellow;
  color: @gruvbox-bg;
}

@keyframes blink {
  to {
    background-color: @gruvbox-bg;
    color: @gruvbox-fg;
  }
}

/* Using steps() instead of linear as a timing function to limit cpu usage */
#battery.critical:not(.charging) {
  background-color: @gruvbox-red;
  color: @gruvbox-fg;
  animation-name: blink;
  animation-duration: 0.5s;
  animation-timing-function: steps(12);
  animation-iteration-count: infinite;
  animation-direction: alternate;
}

#idle_inhibitor.activated {
  background-color: @gruvbox-fg;
  color: @gruvbox-bg;
}

/* Remove parent box's padding */
#keyboard-state {
  padding: 0;
  transition-duration: 0;
}

#keyboard-state>label {
  padding: 0 5px; /* TODO HIDPI */
}

#keyboard-state>label.locked {
  background: @gruvbox-fg;
  border-radius: inherit;
  color: @gruvbox-bg;
}

#mpd {
  background-color: @gruvbox-bg;
  color: @gruvbox-fg;
}

#mpd.disconnected {
  background-color: @gruvbox-red;
}

#mpd.paused {
  background-color: @gruvbox-gray;
}

#mpd.stopped {
  background-color: @gruvbox-fg;
  color: @gruvbox-bg;
}

#network.disconnected {
  background-color: @gruvbox-red;
}

#power-profiles-daemon.performance {
  background-color: @gruvbox-red;
  color: @gruvbox-fg;
}

#power-profiles-daemon.balanced {
  background-color: @gruvbox-blue;
  color: @gruvbox-fg;
}

#power-profiles-daemon.power-saver {
  background-color: @gruvbox-green;
  color: @gruvbox-bg;
}

#pulseaudio.muted {
  color: @gruvbox-gray;
}

#temperature.critical {
  background-color: @gruvbox-red;
}

#tray {
  background-color: @gruvbox-fg;
}

#tray>.passive {
  -gtk-icon-effect: dim;
}

#tray>.needs-attention {
  -gtk-icon-effect: highlight;
  background-color: @gruvbox-red;
}

#window,
#workspaces {
  background-color: transparent;
  /* Remove parent box's padding */
  padding: 0;
}

#workspaces button {
  background-color: @gruvbox-bg;
  color: @gruvbox-fg;
  padding: 0 5px; /* TODO HIDPI */
}

#workspaces button:not(:first-child):not(:last-child) {
  border-radius: 0;
}

#workspaces button:first-child {
  border-top-right-radius: 0;
  border-bottom-right-radius: 0;
}

#workspaces button:last-child {
  border-top-left-radius: 0;
  border-bottom-left-radius: 0;
}

#workspaces button:only-child {
  border-radius: 8px;
}

#workspaces button:hover {
  background: @gruvbox-yellow;
  box-shadow: inset 0 -3px @gruvbox-fg;
  color: @gruvbox-bg;
}

/* focused */
#workspaces button.active {
  background-color: @gruvbox-gray;
  color: @gruvbox-bg;
}

#workspaces button.urgent {
  background-color: @gruvbox-purple;
}

/* When no windows are in the workspace */
/* window#waybar.empty {
    background-color: transparent;
} */

/* When one tiled window is visible in the workspace (floating windows may be present) */
/* window#waybar.solo {
    background-color: #FFFFFF;
} */

#privacy {
  /* Privacy is missing class .module */
  margin-left: 2px; /* TODO HIDPI */
  margin-right: 2px; /* TODO HIDPI */
  /* Remove parent box's padding */
  padding: 0;
  background-color: @gruvbox-fg;
  color: @gruvbox-bg;
}

#privacy-item {
  padding: 0 5px; /* TODO HIDPI */
}

/* Concatnate modules CPU, Memory, Temperature */
#cpu {
  margin-right: 0;
  border-top-right-radius: 0;
  border-bottom-right-radius: 0;
}

#memory {
  margin-left: 0;
  margin-right: 0;
  border-radius: 0;
}

#temperature {
  margin-left: 0;
  border-top-left-radius: 0;
  border-bottom-left-radius: 0;
}'';
    settings = [
      {
        margin-left = 4;
        margin-right = 4;
        margin-top = 6;
        output = ["eDP-1"];
        modules-left = ["hyprland/workspaces" "hyprland/submap"];
        modules-center = ["hyprland/window"];
        modules-right = [
          "mpd"
          "idle_inhibitor"
          "pulseaudio"
          "network"
          "power-profiles-daemon"
          "cpu"
          "memory"
          "temperature"
          "backlight"
          "keyboard-state"
          "battery"
          "clock"
          "tray"
          "privacy"
        ];
        "hyprland/workspaces" = {
          format = "{name}{windows}";
          show-special = true;
          special-visible-only = true;
          window-rewrite = {
            "class<ario>" = "&#xf0386;"; # music_circle
            "class<blender>" = "&#xf00ab;"; # blender_software
            "class<blueman-manager>" = "&#xf293;"; # nf-fa-bluetooth
            "class<com.obsproject.Studio>" = "&#xf0210;"; # fan
            "class<firefox>" = "&#xf0239;"; # firefox
            "class<gamescope>" = "&#xf0297;"; # gamepad_variant
            "class<hyprland-share-picker>" = "&#xf0496;"; # share
            "class<imv>" = "&#xf02e9;"; # image
            "class<localsend>" = "&#xf04b8;"; # soccer
            "class<mpv>" = "&#xf36e;"; # linux-mpv
            "class<org.fcitx.fcitx5-config-qt>" = "&#xf09f9;"; # keyboard_settings
            "class<org.gnome.Nautilus>" = "&#xf024b;"; # folder
            "class<org.inkscape.Inkscape>" = "&#xf33b;"; # linux-inkscape
            "class<org.pwmt.zathura>" = "&#xf292;"; # hashtag
            "class<org.remmina.Remmina>" = "&#xeb39;"; # nf-md-remote
            "class<org.telegram.desktop>" = "&#xf2c6;"; # telegram
            "class<python3>" = "&#xf0320;"; # nf-md-language_python
            "class<steam|SDL Application>" = "&#xf04d3;"; # steam
            "class<waybar>" = "&#xebdc;"; # debug_all
            "class<Alacritty>" = "&#xf018d;"; # console
            "class<Anki>" = "&#xf0638;"; # cards
            "class<KeePassXC>" = "&#xf0bc4;"; # shield_key
            "class<Minecraft|modrinth-app>" = "&#xf0373;"; # minecraft
          };
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "&#xf1802;"; # nf-md-lightbulb_variant
            deactivated = "&#xf0336;"; # nf-md-lightbulb_outline
          };
        };
        tray = {
          icon-size = 20;
          spacing = 6;
        };
        clock = {
          actions = {
            on-click-right = "tz_down";
            on-scroll-up = "tz_up";
            on-scroll-down = "tz_down";
          };
          format = "{:%H:%M:%S (%Z)}";
          format-alt = "{:%m-%d-%y}";
          interval = 1;
          timezones = [
            "Asia/Hong_Kong"
            "Europe/London"
            "US/Eastern"
          ];
          tooltip-format = "<big>{:%y %b}</big>\n<tt><small>{calendar}</small></tt>";
        };
        cpu = {
          format = "{usage}% &#xf0ee0;"; # cpu_64_bit
          tooltip = false;
        };
        memory = {
          format = "{percentage}% &#xf035b;"; # memory
        };
        temperature = {
          hwmon-path = "/sys/class/hwmon/hwmon5/temp1_input";
          critical-threshold = 80;
          format-critical = "{temperatureC}&#xb0;C &#xf0e01;"; # thermometer_alert
          format = "{temperatureC}&#xb0;C {icon}";
          format-icons = [
            "&#xf10c3;" # thermometer_low
            "&#xf050f;" # thermometer
            "&#xf10c2;" # thermometer_high
          ];
          tooltip = false;
        };
        backlight = {
          # on-scroll-up = "brightnessctl set +4%"; # Some devices may need set manually
          # on-scroll-down = "brightnessctl set 4%-";
          format = "{percent}% {icon}";
          format-icons = [
            "&#xf00da;" # brightness_1
            "&#xf00db;" # brightness_2
            "&#xf00dc;" # brightness_3
            "&#xf00de;" # brightness_5
            "&#xf00dd;" # brightness_4
            "&#xf00df;" # brightness_6
            "&#xf00e0;" # brightness_5
          ];
          tooltip = false;
        };
        keyboard-state = {
          numlock = false;
          capslock = true;
          format = "{name} {icon}";
          format-icons = {
            locked = "&#xf0a9b;"; # caps_lock
            unlocked = "&#xf030e;"; # keyboard_caps
          };
        };
        battery = {
          states = {
            # good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-full = "{capacity}% {icon}";
          format-charging = "{capacity}% &#xf0084;"; # battery_charging
          format-plugged = "{capacity}% &#xf1834;"; # battery_sync
          format-alt = "{time} {power}W {icon}";
          # format-good = ""; # an empty format will hide the module
          # format-full = "";
          format-icons = [
            "&#xf10cd;" # battery_alert_variant_outline
            "&#xf007a;" # battery_10
            "&#xf007b;" # battery_20
            "&#xf007c;" # battery_30
            "&#xf007d;" # battery_40
            "&#xf007e;" # battery_50
            "&#xf007f;" # battery_60
            "&#xf0080;" # battery_70
            "&#xf0081;" # battery_80
            "&#xf0082;" # battery_90
            "&#xf0079;" # battery
          ];
        };
        power-profiles-daemon = {
          format = "{icon}";
          tooltip-format = "power profile: {profile}\ndriver: {driver}";
          tooltip = true;
          format-icons = {
            default = "&#xf0210;"; # fan
            performance = "&#xf1807;"; # fire_circle
            balanced = "&#xf1a04;"; # percent_circle
            power-saver = "&#xf1905;"; # leaf_circle
          };
        };
        network = {
          interface = "wlan0"; # TODO
          format-wifi = "{icon}";
          format-ethernet = "{ipaddr}/{cidr} &#xf0200;"; # ethernet
          format-linked = "{ifname} (no ip) &#xf0318;"; # lan_connect
          format-disconnected = "disconnected &#xf0319;"; # lan_disconnect
          format-alt = "{ifname}: {ipaddr}/{cidr}";
          tooltip-format = "{ifname} via {gwaddr} &#xf11e2;"; # router
          tooltip-format-wifi = "{essid} ({signalStrength}%)\n{ifname} via {gwaddr} &#xf11e2;"; # router
          format-icons = [
            "&#xf092f;" # wifi_strength_outline
            "&#xf091f;" # wifi_strength_1
            "&#xf0922;" # wifi_strength_2
            "&#xf0925;" # wifi_strength_3
            "&#xf0928;" # wifi_strength_4
          ];
        };
        pulseaudio = {
          # scroll-step = 1, # %, can be a float
          format = "{volume}% {icon} {format_source}";
          format-muted = "&#xf0581; {format_source}"; # volume_off
          format-bluetooth = "{volume}% {icon}&#xf00af; {format_source}"; # bluetooth
          format-bluetooth-muted = "&#xf0581;{icon}&#xf00af; {format_source}"; # volume_off, bluetooth
          format-source = "{volume}% &#xf036c;"; # microphone
          format-source-muted = "&#xf036d;"; # microphone_off
          format-icons = {
            headphone = "&#xf02cb;"; # headphones
            hands-free = "&#xf184f;"; # earbuds
            headset = "&#xf02ce;"; # headset
            phone = "&#xf03f2;"; # phone
            portable = "&#xf011c;"; # cellphone
            car = "&#xf010b;"; # car
            default = [
              "&#xf057f;" # volume_low
              "&#xf0580;" # volume_medium
              "&#xf057e;" # volume_high
            ];
          };
          on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          on-click-right = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        };
        privacy = {
          icon-spacing = 4;
          icon-size = 18;
          transition-duration = 250;
          modules = [
            {
              type = "screenshare";
              tooltip = true;
              tooltip-icon-size = 22;
            }
            {
              type = "audio-out";
              tooltip = true;
              tooltip-icon-size = 22;
            }
            {
              type = "audio-in";
              tooltip = true;
              tooltip-icon-size = 22;
            }
          ];
        };
        mpd = {
          title-len = 10;
          format = "{stateIcon}{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) &#xf075a;"; # music
          format-disconnected = "Disconnected &#xf0319;"; # lan_disconnect
          format-stopped = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped &#xf075b;"; # music_off
          interval = 10;
          consume-icons = {
            on = "&#xf0190;"; # content_cut
          };
          random-icons = {
            off = "&#xf049e;"; # shuffle_disabled
            on = "&#xf049d;"; # shuffle
          };
          repeat-icons = {
            on = "&#xf0456;"; # repeat
          };
          single-icons = {
            on = "&#xf0458;"; # repeat_once
          };
          state-icons = {
            paused = "&#xf03e4;"; # pause
            playing = "&#xf040a;"; # play
          };
          tooltip-format = "MPD (connected)";
          tooltip-format-disconnected = "MPD (disconnected)";
        };
      }
    ];
  };
}
