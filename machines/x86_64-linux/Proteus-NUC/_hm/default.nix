{lib, mylib, pkgs, ...}: let
  dpi_scale = lib.strings.substring 0 4 (lib.strings.floatToString 1.25);
  # Ref: https://wiki.hyprland.org/Configuring/Monitors/
  # ls /sys/class/drm/card*
  main_monitor = "eDP-1,highres,auto,${dpi_scale},bitdepth,10";
  secondary_monitor = "DP-3,highres,auto-left,2,bitdepth,10";
in {
  imports = mylib.scan_path ./.;
  home.packages = [pkgs.nvtopPackages.intel];
  wayland.windowManager.hyprland = {
    # nvidia = true; # Sync prime
    settings = {
      # Configure your Display resolution, offset, scale and Monitors here, use `hyprctl monitors` to get the info.
      #   highres:      get the best possible resolution
      #   auto:         position automatically
      #   bitdepth,10:  enable 10 bit support
      monitor = [main_monitor secondary_monitor];
      workspace = let
        main_iface = builtins.head (lib.strings.splitString "," main_monitor);
        secondary_iface = builtins.head (lib.strings.splitString "," secondary_monitor);
      in [
        "1,monitor:${main_iface}"
        "2,monitor:${main_iface}"
        "3,monitor:${main_iface}"
        "4,monitor:${main_iface}"
        "5,monitor:${main_iface}"
        "6,monitor:${secondary_iface}"
        "7,monitor:${secondary_iface}"
        "8,monitor:${secondary_iface}"
        "9,monitor:${secondary_iface}"
        "10,monitor:${secondary_iface}"
      ];
      env = [
        "GDK_DPI_SCALE,${dpi_scale}"
        "STEAM_FORCE_DESKTOPUI_SCALING,${dpi_scale}"
      ];
      bindl = [
        ",switch:on:Lid Switch,exec,[ $(hyprctl monitors -j | jq '.[].name' | wc -w) -ne 1 ] && hyprctl keyword monitor \"${main_monitor},disable\"" # Going to dock mode if has external monitor connected
        ",switch:off:Lid Switch,exec,hyprctl keyword monitor \"${main_monitor}\"" # Restore internal monitor
      ];
      device = {
        name = "microsoft-surface-type-cover-touchpad";
        sensitivity = 0.3;
      };
    };
  };
  services.hypridle.settings.general = {
    lock_cmd = "lock_cmd = pidof hyprlock || (brightnessctl -sd usb-3-11-3-1::kbd_backlight set 0; hyprlock && loginctl unlock-session)";
    unlock_cmd = "brightnessctl -rd usb-3-11-3-1::kbd_backlight";
  };
  programs.mpv.profiles.common.vulkan-device = "Intel(R) UHD Graphics (TGL GT1)";
  # programs.ssh = {
  #   enable = true;
  #   enableDefaultConfig = false;
  #   matchBlocks = {
  #     "*" = { # Default values
  #       # A private key that is used during authentication will be added to
  #       # ssh-agent if it is running
  #       addKeysToAgent = "yes";
  #       # Allow to securely use local SSH agent to authenticate on the remote
  #       # machine. It has the same effect as adding cli option `ssh -A user@host`
  #       forwardAgent = true;
  #     };
  #     "ssh.github.com hf.co" = lib.hm.dag.entryBefore ["*.tailba6c3f.ts.net"] {
  #       user = "git";
  #       identityFile = "~/sync_work/keys/private/proteus_ed25519.key";
  #       identitiesOnly = true; # Prevent sending default identity files first.
  #     };
  #     "192.168.*" = {
  #       identityFile = "/etc/agenix/ssh-key-romantic"; # romantic holds my homelab~
  #       identitiesOnly = true; # Specifies that ssh should only use the identity file. Required to prevent sending default identity files first.
  #     };
  #   };
  # };
  # modules.editors.emacs.enable = true;
}
