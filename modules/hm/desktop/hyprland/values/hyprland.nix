{pkgs, nur-ryan4yin, ...}: let
  package = pkgs.hyprland;
in {
  wayland.windowManager.hyprland = {
    inherit package;
    enable = true;
    settings = {
      source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-hyprland}/themes/mocha.conf"; # Import color codes
      "$terminal" = "systemd-run --user --scope alacritty";
      "$menu" = "systemd-run --user --scope rofi -show combi";
      "$clipManager" = "systemd-run --user --scope sh -c 'cliphist list | rofi -dmenu | cliphist decode | wl-copy'";
      "$mainMod" = "SUPER";
      bind = [
        "$mainMod,E,exec,$fileManager"
        "$mainMod,Q,exec,$terminal"
        "$mainMod,W,killactive,"
        "$mainMod,SPACE,exec,$menu"
        "$mainMod,V,exec,$clipManager"
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
      ];
      binde = [
        "$mainMod ALT,H,resizeactive,-5% 0"
        "$mainMod ALT,L,resizeactive,5% 0"
        "$mainMod ALT,J,resizeactive,0 5%"
        "$mainMod ALT,K,resizeactive,0 -5%"
      ];
      bindl = [
        "$mainMod,Z,exec,loginctl lock-session; sleep 0.6; hyprctl dispatch dpms off"
        "$mainMod ALT,Q,exit," # Exit Hyprland
        "$mainMod ALT,X,exec,systemctl suspend" # Suspend
        "$mainMod ALT,C,exec,systemctl hibernate" # Hibernate
        "$mainMod ALT,R,exec,systemctl reboot" # Reboot
        "$mainMod ALT,S,exec,systemctl poweroff" # Shutdown
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
      env = [
        # "NIXOS_OZONE_WL,1" # for any ozone-based browser & electron apps to run on wayland TODO may be unnecessary
        "_JAVA_AWT_WM_NONREPARENTING,1"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1" # Disables window decorations on Qt applications
        # "QT_QPA_PLATFORMTHEME,qt6ct"
        "QT_QPA_PLATFORM,wayland"
        "SDL_VIDEODRIVER,wayland"
        "GDK_BACKEND,wayland"
        "QT_ENABLE_HIGHDPI_SCALING,1"
      ];
      exec-once = [
        "~/.config/hypr/scripts/startup"
      ];
      general = {
        border_size = 2;
        gaps_in = 2; # gaps between windows
        gaps_out = 5; # gaps between windows and monitor edges
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
      };
      misc = {
        mouse_move_enables_dpms = false;
        key_press_enables_dpms = true;
        vrr = 1;
      };
      windowrulev2 = [
        "idleinhibit focus,class:^(firefox)$"
        "float,class:^(firefox)$,title:^(Picture-in-Picture)$"
        "pin,class:^(firefox)$,title:^(Picture-in-Picture)$"
        "size 480 270,class:^(firefox)$,title:^(Picture-in-Picture)$"
        "move 100%-w-5 100%-w-5,class:^(firefox)$,title:^(Picture-in-Picture)$"
      ];
    };
    # extraConfig = builtins.readFile ../conf/hyprland.conf;
    systemd.variables = ["--all"];
  };
  services.cliphist.enable = true;

  # NOTE: this executable is used by greetd to start a wayland session when system boot up
  # with such a vendor-no-locking script, we can switch to another wayland compositor without modifying greetd's config in NixOS module
  home.file.".wayland-session" = {
    source = "${package}/bin/Hyprland";
    executable = true;
  };

  # hyprland configs, based on https://github.com/notwidow/hyprland
  xdg.configFile = {
    "hypr/mako" = {
      source = ../conf/mako;
      recursive = true;
    };
    "hypr/scripts" = {
      source = ../conf/scripts;
      recursive = true;
    };
    "hypr/waybar" = {
      source = ../conf/waybar;
      recursive = true;
    };
    "hypr/wlogout" = {
      source = ../conf/wlogout;
      recursive = true;
    };

    # music player - mpd
    "mpd" = {
      source = ../conf/mpd;
      recursive = true;
    };
  };
}
