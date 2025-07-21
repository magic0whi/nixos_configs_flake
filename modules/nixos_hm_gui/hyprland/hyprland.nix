{pkgs, lib, config, myvars, ...}: with lib; let
  package = pkgs.hyprland;
in {
  home.file.".wayland-session" = { # NOTE: this executable is used by greetd to start a wayland session when system boot up. With such a vendor-no-locking script, we can switch to another wayland compositor without modifying greetd's config in NixOS module
    source = "${package}/bin/Hyprland";
    executable = true;
  };
  wayland.windowManager.hyprland = {
    inherit package;
    enable = true;
    settings = {
      source = "${pkgs.catppuccin}/hyprland/${myvars.catppuccin_variant}.conf"; # Import color codes
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
      "$clipManager" = "systemd-run --user --scope sh -c 'cliphist list | anyrun --show-results-immediately true | cliphist decode | wl-copy'";
      "$colorpicker" = "~/.config/hypr/scripts/colorpicker"; # TODO use Hyprpicker instead
      "$fileManager" = "systemd-run --user --scope thunar";
      "$backlight" = "~/.config/hypr/scripts/brightness";
      "$volume" = "~/.config/hypr/scripts/volume";
      "$wlogout" = "~/.config/hypr/scripts/wlogout";
      "$mainMod" = "SUPER";
      bind = [
        "$mainMod,E,exec,$fileManager"
        "$mainMod,Q,exec,$terminal"
        "$mainMod,W,killactive,"
        "$mainMod,SPACE,exec,$menu"
        "$mainMod,V,exec,$clipManager"
        "$mainMod CTRL,P,exec,$colorpicker"
        "$mainMod,X,exec,$wlogout"
        "$mainMod,F,fullscreen,"
        "$mainMod SHIFT,F,togglefloating"
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

        # Move/resize windows
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
      binde = [
        "$mainMod ALT,H,resizeactive,-5% 0"
        "$mainMod ALT,L,resizeactive,5% 0"
        "$mainMod ALT,J,resizeactive,0 5%"
        "$mainMod ALT,K,resizeactive,0 -5%"
      ];
      bindel = [ # Multimedia keys for volume and brightness
        ",XF86AudioRaiseVolume,exec,$volume -inc"
        ",XF86AudioLowerVolume,exec,$volume -dec"
        ",XF86AudioMute,exec,$volume --toggle"
        ",XF86AudioMicMute,exec,$volume --toggle-mic"
        ",XF86MonBrightnessUp,exec,$backlight --inc"
        ",XF86MonBrightnessDown,exec,$backlight --dec"
        ",XF86AudioNext,exec,mpc next"
        ",XF86AudioPrev,exec,mpc prev"
        ",XF86AudioPlay,exec,mpc toggle"
        ",XF86AudioStop,exec,mpc stop"
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
        "_JAVA_AWT_WM_NONREPARENTING,1"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1" # Disables window decorations on Qt applications
        "QT_QPA_PLATFORMTHEME,qt6ct"
        "QT_QPA_PLATFORM,wayland"
        "SDL_VIDEODRIVER,wayland"
        "GDK_BACKEND,wayland"
        "QT_ENABLE_HIGHDPI_SCALING,1"
      ];
      general = {
        border_size = 2;
        gaps_in = 2; # gaps between windows
        gaps_out = 5; # gaps between windows and monitor edges
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
      };
      gestures.workspace_swipe = true;
      misc = {
        key_press_enables_dpms = true;
        vrr = 1;
      };
      windowrule = [
        "float,class:^(yad|org\.pulseaudio\.pavucontrol|imv|qemu)$"
        "float,class:^(thunar)$,title:^(File Operation Progress)$"

        "idleinhibit focus,class:^(firefox)$"
        "float,class:^(firefox)$,title:^(Picture-in-Picture)$"
        "pin,class:^(firefox)$,title:^(Picture-in-Picture)$"
        "size 480 270,class:^(firefox)$,title:^(Picture-in-Picture)$"
        "move 100%-w-5 100%-w-5,class:^(firefox)$,title:^(Picture-in-Picture)$"

        "float, class:^(anki)$, title:(HyperTTS: Add Audio \(Collection\))"
        "size 1090 640, class:(anki), title:(HyperTTS: Add Audio \(Collection\))"

        "float, class:^(org\.inkscape\.Inkscape)$, title:^(Function Plotter)$"
        "float, class:^(org\.inkscape\.Inkscape)$, title:^(Function Plotter)$"
      ];
      xwayland.force_zero_scaling = true; # This will get rid of the pixelated look, but will not scale applications properly. To do this, each toolkit has its own mechanism.
    };
    systemd.variables = ["--all"];
  };
  services.hypridle = { # For dbus' loginctl lock/unlock
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof swaylock || (swaylock && loginctl unlock-session)";
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
  programs.hyprlock = {
    enable = mkDefault false; # TODO hyprlock is still experimental
    settings = {
      background = [{
        blur_passes = 0; # 0 disables blurring
        blur_size = 7;
        brightness = 0.8172;
        color = "rgba(25, 20, 20, 1.0)";
        contrast = 0.8916;
        noise = 0.0117;
        path = "${config.xdg.userDirs.pictures}/background.png"; # supports png, jpg, webp (no animations, though)
        # If 'path' is invalid, will use 'color'
        vibrancy = 0.1696;
        vibrancy_darkness = 0.0;
      }];
      image = [{
        border_color = "rgb(221, 221, 221)";
        border_size = 4;
        halign = "center";
        path = "${config.xdg.userDirs.pictures}/avatar.png";
        position = "0, 200";
        reload_time = -1; # seconds between reloading, 0 to reload with SIGUSR2
        rotate = 0; # degrees, counter-clockwise
        rounding = -1; # negative values mean circle
        size = 150; # lesser side if not 1:1 ratio
        valign = "center";
      }];
      input-field = [{
        bothlock_color = -1; # when both locks are active. -1 means don't change outer color (same for above)
        capslock_color = -1;
        check_color = "rgb(204, 136, 34)";
        dots_center = false;
        dots_rounding = -1; # -1 default circle, -2 follow input-field rounding
        dots_size = 0.33; # Scale of input-field height, 0.2 - 0.8
        dots_spacing = 0.15; # Scale of dots' absolute size, 0.0 - 1.0
        fade_on_empty = true;
        fade_timeout = 1000; # Milliseconds before fade_on_empty is triggered.
        fail_color = "rgb(204, 34, 34)"; # if authentication failed, changes outer_color and fail message color
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>"; # can be set to empty
        fail_transition = 300; # transition time in ms between normal outer_color and fail_color
        font_color = "rgb(10, 10, 10)";
        halign = "center";
        hide_input = false;
        inner_color = "rgb(200, 200, 200)";
        invert_numlock = false; # change color if numlock is off
        numlock_color = -1;
        outer_color = "rgb(151515)";
        outline_thickness = 3;
        placeholder_text = "<i>Input Password...</i>"; # Text rendered in the input box when it's empty.
        position = "0, -20";
        rounding = -1; # -1 means complete rounding (circle/oval)
        size = "200, 50";
        swap_font_color = false; # see below
        valign = "center";
      }];
      shape = [{
        border_color = "rgba(0, 207, 230, 1.0)";
        border_size = 8;
        color = "rgba(17, 17, 17, 0.8)";
        halign = "center";
        position = "0, 0";
        rotate = 0;
        rounding = 69;
        size = "360, 360";
        valign = "center";
        xray = false; # if true, make a "hole" in the background (rectangle of specified size, no rotation)
      }];
      label = [{
        color = "rgba(200, 200, 200, 1.0)";
        font_family = "Noto Sans";
        font_size = 25;
        halign = "center";
        position = "0, 80";
        rotate = 0; # degrees, counter-clockwise
        text = "Hi there, $USER";
        text_align = "center"; # center/right or any value for default left. multi-line text alignment inside label container
        valign = "center";
      }];
    };
  };
  services.cliphist.enable = true;
  xdg.configFile = { # hyprland configs, based on https://github.com/notwidow/hyprland
    "hypr/mako" = { # Keep icon files
      source = ./_conf/mako;
      recursive = true;
    };
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
