{lib, mylib, pkgs, config, myvars, ...}: let
  dpi_scale = lib.strings.substring 0 4 (lib.strings.floatToString 1.25);
  # Ref: https://wiki.hyprland.org/Configuring/Monitors/
  # ls /sys/class/drm/card*
  main_monitor = if config.wayland.windowManager.hyprland.nvidia then
    # 10-bit will cause the internal monitor flickering when using PRIME Sync
    "eDP-1,highres,auto,${dpi_scale},bitdepth,8,cm,adobe"
  else
    "eDP-1,highres,auto,${dpi_scale},bitdepth,10,cm,adobe";
  secondary_monitor = "HDMI-A-1,highres,auto-left,2,bitdepth,10,cm,adobe";
  third_monitor = "DP-3,highres,auto-left,1.67,bitdepth,10,cm,adobe";
in {
  imports = mylib.scan_path ./.;
  ## START nix.nix
  xdg.configFile."nix/public.key".source = "${myvars.secrets_dir}/nix-public.key";
  age.secrets = {
    "nix-secret.key" = {
      file = "${myvars.secrets_dir}/nix-secret.key.age";
      mode = "0400";
      path = "${config.xdg.configHome}/nix/secret.key";
    };
    "aws_credentials" = {
      file = "${myvars.secrets_dir}/aws_credentials.age";
      mode = "0400";
      path = "${config.home.homeDirectory}/.aws/credentials";
    };
  };
  ## END nix.nix
  home.packages = with pkgs; [
    (nvtopPackages.intel.override {nvidia = true;})
    minicom # embedded development
    xmrig xmrig-cuda # Heating & Mining
    chezmoi
    libreoffice
    qpdf
    act # Run your Github Actions locally
  ];
  wayland.windowManager.hyprland = {
    # nvidia = true; # Prime Sync
    settings = {
      # Configure your Display resolution, offset, scale and Monitors here, use
      # `hyprctl monitors` to get the info.
      #   highres:     get the best possible resolution
      #   auto:        position automatically
      #   bitdepth,10: enable 10 bit support
      monitor = [main_monitor secondary_monitor third_monitor];
      workspace = let
        main_iface = builtins.head (lib.strings.splitString "," main_monitor);
        secondary_iface = builtins.head (lib.strings.splitString "," secondary_monitor);
        third_iface = builtins.head (lib.strings.splitString "," third_monitor);
      in [
        "1,monitor:${third_iface}"
        "2,monitor:${third_iface}"
        "3,monitor:${third_iface}"
        "4,monitor:${third_iface}"
        "5,monitor:${secondary_iface}"
        "6,monitor:${secondary_iface}"
        "7,monitor:${secondary_iface}"
        "8,monitor:${main_iface}"
        "9,monitor:${main_iface}"
        "10,monitor:${main_iface}"
      ];
      env = [
        # Not recommand set globally, make firefox scale twice
        # "GDK_DPI_SCALE,${dpi_scale}"
        "STEAM_FORCE_DESKTOPUI_SCALING,${dpi_scale}"
      ] ++ lib.optional # PRIME Sync mode for Hyprland
        config.wayland.windowManager.hyprland.nvidia
        "AQ_DRM_DEVICES,/dev/dri/${myvars.dgpu_sym_name}:/dev/dri/${myvars.igpu_sym_name}";

      bind = [
        # Leave to main monitor for sunshine streaming
        (builtins.concatStringsSep "" [
          "$mainMod,Y,exec,"
          "hyprctl keyword monitor "
          "\"${builtins.head (lib.strings.splitString "," secondary_monitor)},disable\""
          "; hyprctl keyword monitor "
          "\"${builtins.head (lib.strings.splitString "," third_monitor)},disable\""
          "; notify-send \"Hyprland\" \"Leave mode: on\""
        ])
        # Restore the three monitors
        (builtins.concatStringsSep "" [
          "$mainMod SHIFT,Y,exec,"
          "hyprctl keyword monitor \"${secondary_monitor}\""
          ";hyprctl keyword monitor \"${third_monitor}\""
          ";notify-send \"Hyprland\" \"Leave mode: off\""
        ])
      ];
      bindl = [
        # Going to dock mode if has external monitor connected
        (builtins.concatStringsSep "" [
          ",switch:on:Lid Switch,exec,"
          # Hyprland interprets commands starting with [ as window rules, change
          # it to `test`
          "test $(hyprctl monitors -j | jq '.[].name' | wc -w) -ne 1"
          " && hyprctl keyword monitor \"${
            builtins.head (lib.strings.splitString "," main_monitor)
          },disable\""
        ])
        # Restore internal monitor
        ",switch:off:Lid Switch,exec,hyprctl keyword monitor \"${
          main_monitor
        }\""
      ];
      # Cause black screen if the bandwidth doesn't enough
      # render = {cm_auto_hdr = 0; cm_fs_passthrough = 0;};
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
  services.mpd.musicDirectory = "/srv/sync/Music";
}
