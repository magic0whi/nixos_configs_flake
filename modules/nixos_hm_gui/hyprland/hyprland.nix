{pkgs, lib, ...}: let
  hypr_pkg = pkgs.hyprland;
in {
  home.file.".wayland-session" = { # NOTE: this executable is used by greetd to start a wayland session when system boot up. With such a vendor-no-locking script, we can switch to another wayland compositor without modifying greetd's config in NixOS module
    source = "${hypr_pkg}/bin/Hyprland";
    executable = true;
  };
  wayland.windowManager.hyprland = {
    enable = true;
    package = hypr_pkg;
    settings = {
      animations = {
        bezier = [
          "easeOutQuint,0.23,1,0.32,1" # https://easings.net/#easeOutQuint
          "linear,0,0,1,1" # https://cubic-bezier.com/#0,0,1,1
          "almostLinear,0.5,0.5,0.75,1.0" # https://cubic-bezier.com/#.5,.5,.75,1
          "quick,0.15,0,0.1,1" # https://cubic-bezier.com/#.15,0,.1,1
        ];
        animation = [
          "global,1,10,default"
          "border,1,5.39,easeOutQuint"
          "windows,1,4.79,easeOutQuint"
          "windowsIn,1,4.1,easeOutQuint,popin 87%"
          "windowsOut,1,1.49,linear,popin 87%"
          "fade,1,3.03,quick"
          "fadeIn,1,1.73,almostLinear"
          "fadeOut,1,1.46,almostLinear"
          "layers,1,3.81,easeOutQuint"
          "layersIn,1,4,easeOutQuint,fade"
          "layersOut,1,1.5,linear,fade"
          "fadeLayersIn,1,1.79,almostLinear"
          "fadeLayersOut,1,1.39,almostLinear"
          "workspaces,1,1.94,almostLinear,fade"
          "workspacesIn,1,1.21,almostLinear,fade"
          "workspacesOut,1,1.94,almostLinear,fade"
        ];
      };
      "$terminal" = "systemd-run --user --scope alacritty";
      "$menu" = "systemd-run --user --scope ~/.config/hypr/scripts/menu";
      # "$menu" = "systemd-run --user --scope rofi -show combi"
      "$clip_manager" = "systemd-run --user --scope sh -c 'cliphist list | anyrun --show-results-immediately true | cliphist decode | wl-copy'";
      # "$clip_manager" = "systemd-run --user --scope sh -c 'cliphist list | rofi -dmenu | cliphist decode | wl-copy'";
      "$colorpicker" = "~/.config/hypr/scripts/colorpicker";
      "$file_manager" = "systemd-run --user --scope thunar";
      "$wlogout" = "~/.config/hypr/scripts/wlogout";
      "$mainMod" = "SUPER";
      bind = [ # TODO make current focused window sticky (e.g. For mpv)
        "$mainMod,E,exec,$file_manager"
        "$mainMod,Q,exec,$terminal"
        "$mainMod,W,killactive,"
        "$mainMod,SPACE,exec,$menu"
        "$mainMod,V,exec,$clip_manager"
        "$mainMod CTRL,P,exec,$colorpicker"
        "$mainMod,X,exec,$wlogout"
        "$mainMod,F,fullscreen,"
        "$mainMod SHIFT,F,togglefloating"
        "$mainMod,G,exec,hyprctl dispatch setfloating && hyprctl dispatch pin"
        "$mainMod,G,setfloating"
        "$mainMod,T,togglesplit," # dwindle
        "$mainMod SHIFT,P,pseudo" # dwindle"

        # Special workspace (scratchpad)
        "$mainMod,S,togglespecialworkspace,magic"
        "$mainMod SHIFT,S,movetoworkspace,special:magic"

        # Move focus
        "$mainMod,H,movefocus,l"
        "$mainMod,L,movefocus,r"
        "$mainMod,K,movefocus,u"
        "$mainMod,J,movefocus,d"
        "$mainMod,N,cyclenext,"
        "$mainMod,P,cyclenext,prev"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod,1,workspace,1"
        "$mainMod,2,workspace,2"
        "$mainMod,3,workspace,3"
        "$mainMod,4,workspace,4"
        "$mainMod,5,workspace,5"
        "$mainMod,6,workspace,6"
        "$mainMod,7,workspace,7"
        "$mainMod,8,workspace,8"
        "$mainMod,9,workspace,9"
        "$mainMod,0,workspace,10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT,1,movetoworkspace,1"
        "$mainMod SHIFT,2,movetoworkspace,2"
        "$mainMod SHIFT,3,movetoworkspace,3"
        "$mainMod SHIFT,4,movetoworkspace,4"
        "$mainMod SHIFT,5,movetoworkspace,5"
        "$mainMod SHIFT,6,movetoworkspace,6"
        "$mainMod SHIFT,7,movetoworkspace,7"
        "$mainMod SHIFT,8,movetoworkspace,8"
        "$mainMod SHIFT,9,movetoworkspace,9"
        "$mainMod SHIFT,0,movetoworkspace,10"

        # Move windows
        "$mainMod SHIFT,H,movewindow,l"
        "$mainMod SHIFT,J,movewindow,d"
        "$mainMod SHIFT,K,movewindow,u"
        "$mainMod SHIFT,L,movewindow,r"

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod,mouse_down,workspace,e+1"
        "$mainMod,mouse_up,workspace,e-1"

        # Functional keys
        ",Print,exec,hyprshot -m output -o ~/Pictures/Screenshots -- imv"
        "ALT,Print,exec,hyprshot -m window -o ~/Pictures/Screenshots -- imv"
        "CTRL,Print,exec,hyprshot -m region -o ~/Pictures/Screenshots -- imv"
      ];
      binde = [ # Resize windows
        "$mainMod ALT,H,resizeactive,-5% 0"
        "$mainMod ALT,L,resizeactive,5% 0"
        "$mainMod ALT,J,resizeactive,0 5%"
        "$mainMod ALT,K,resizeactive,0 -5%"
      ];
      bindel = [ # Multimedia keys for volume and brightness
        ",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute,exec,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute,exec,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp,exec,brightnessctl set +4%"
        ",XF86MonBrightnessDown,exec,brightnessctl set 4%-"
        ",XF86AudioNext,exec,mpc next" # Or `playerctl --all-players next`
        ",XF86AudioPrev,exec,mpc prev" # Or `playerctl --all-players previous`
        ",XF86AudioPlay,exec,mpc toggle" # Or `playerctl --all-players play-pause`
        ",XF86AudioStop,exec,mpc stop" # Or `playerctl --all-players stop`
      ];
      bindl = [
        "$mainMod,Z,exec,loginctl lock-session; sleep 0.6; hyprctl dispatch dpms off"
        "$mainMod ALT,Q,exit," # Exit Hyprland
        "$mainMod ALT,X,exec,systemctl suspend" # Suspend
        "$mainMod ALT,C,exec,systemctl hibernate" # Hibernate
        "$mainMod ALT,R,exec,systemctl reboot" # Reboot
        "$mainMod ALT,S,exec,systemctl poweroff" # Shutdown
        ",switch:Lid Switch,exec,loginctl lock-session" # Lock when lid switch triggered
      ];
      bindm = [ # LMB/RMB and dragging to move/resize windows
        "$mainMod,mouse:272,movewindow"
        "$mainMod,mouse:273,resizewindow"
      ];
      gesture = ["3, horizontal, workspace"];
      decoration = {
        rounding = 10;

        active_opacity = 1.0;
        inactive_opacity = 0.9;
        fullscreen_opacity = 1.0;

        # Your blur "amount" is blur:size * blur:passes, but high blur_size (over around 5-ish) will produce artifacts. If you want heavy blur, you need to up the blur_passes. The more passes, the more you can up the blur:size without noticeable artifacts.
        "blur:enabled" = false;
        # "blur:size" = 3;
        # "blur:ignore_opacity" = false;
        "shadow:enabled" = false;
      };
      dwindle = {
        pseudotile = true; # Master switch for pseudotiling
        preserve_split = true; # The split (side/top) will not change regardless of what happens to the container
      };
      env = [
        # "_JAVA_AWT_WM_NONREPARENTING,1"
        # "QT_WAYLAND_DISABLE_WINDOWDECORATION,1" # Disables window decorations on Qt applications
        # "QT_QPA_PLATFORM,wayland"
        # "SDL_VIDEODRIVER,wayland"
        # "GDK_BACKEND,wayland"
        "QT_ENABLE_HIGHDPI_SCALING,1"
      ];
      general = {
        border_size = 2;
        gaps_in = 2; # gaps between windows
        gaps_out = 5; # gaps between windows and monitor edges
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
      };
      misc = {
        key_press_enables_dpms = true;
        vrr = 1;
      };
      windowrule = [
        "match:class ^yad|org\.pulseaudio\.pavucontrol|imv|qemu$,float true"
        "match:class ^thunar$, match:title ^File Operation Progress$,float true"

        "match:class ^firefox$,idle_inhibit focus"
        "match:class ^firefox$,match:title ^Picture-in-Picture$,float true"
        "match:class ^firefox$,match:title ^Picture-in-Picture$,pin true"
        "match:class ^firefox$,match:title ^Picture-in-Picture$,size 480 270"
        "match:class ^firefox$,match:title ^Picture-in-Picture$,move 100%-w-5 100%-w-5"

        "match:class ^anki$,match:title ^HyperTTS: Add Audio \(Collection\)$,float true"
        "match:class ^anki$,match:title ^HyperTTS: Add Audio \(Collection\)$,size 1090 640"

        "match:class ^org\.inkscape\.Inkscape$,match:title ^Function Plotter$,float true"
        "match:class ^org\.inkscape\.Inkscape$,match:title ^Function Plotter$,float true"
      ];
      xwayland.force_zero_scaling = true; # This will get rid of the pixelated look, but will not scale applications properly. To do this, each toolkit has its own mechanism.
    };
    systemd.variables = ["--all"];
  };
  services.hypridle = { # For dbus' loginctl lock/unlock
    enable = true;
    settings = {
      general = {
        lock_cmd = lib.mkDefault "pidof hyprlock || (hyprlock && loginctl unlock-session)";
        before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
        after_sleep_cmd = "hyprctl dispatch dpms on"; # avoid have to press a key twice to turn on the display.
      };
      listener = [
        {
          timeout = 600; # 10min
          on-timeout = "loginctl lock-session"; # lock screen when timeout has passed
        }
        {
          timeout = 630; # 10.5min
          on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
          on-resume = "hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
        }
      ];
    };
  };
  programs.hyprlock.enable = true;
  services.cliphist.enable = true;
  xdg.configFile = { # hyprland configs, based on https://github.com/notwidow/hyprland
    "hypr/scripts" = {
      source = ./_conf/scripts;
      recursive = true;
    };
    "hypr/wlogout" = {
      source = ./_conf/wlogout;
      recursive = true;
    };
  };
}
