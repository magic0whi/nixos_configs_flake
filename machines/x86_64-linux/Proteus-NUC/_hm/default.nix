{config, lib, mylib, pkgs, ...}: let
  dpi_scale = lib.strings.substring 0 4 (lib.strings.floatToString 1.25);
  main_monitor = "eDP-1";
  modeline = "highres,auto,${dpi_scale},bitdepth,10";
  custom_files_dir = mylib.relative_to_root "custom_files";
in {
  imports = mylib.scan_path ./.;
  home.packages = [pkgs.nvtopPackages.intel];
  modules.gui.hyprland = {
    enable = true;
    # nvidia = true; # Sync prime
    settings = {
      # Configure your Display resolution, offset, scale and Monitors here, use `hyprctl monitors` to get the info.
      #   highres:      get the best possible resolution
      #   auto:         position automatically
      #   bitdepth,10:  enable 10 bit support
      monitor = "${main_monitor},${modeline}";
      env = [
        "GDK_DPI_SCALE,${dpi_scale}"
        "STEAM_FORCE_DESKTOPUI_SCALING,${dpi_scale}"
      ];
      bindl = [
        ",switch:on:Lid Switch,exec,[ $(hyprctl monitors -j | jq '.[].name' | wc -w) -ne 1 ] && hyprctl keyword monitor \"${main_monitor},disable\"" # Going to dock mode if has external monitor connected
        ",switch:off:Lid Switch,exec,hyprctl keyword monitor \"${main_monitor},${modeline}\"" # Restore internal monitor
      ];
      device = {
        name = "microsoft-surface-type-cover-touchpad";
        sensitivity = 0.3;
      };
    };
    hypridle.settings.general = {
      lock_cmd = "lock_cmd = pidof hyprlock || (brightnessctl -sd usb-3-11-3-1::kbd_backlight set 0; hyprlock && loginctl unlock-session)";
      unlock_cmd = "brightnessctl -rd usb-3-11-3-1::kbd_backlight";
    };
  };
  # modules.editors.emacs.enable = true;
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = { # Default values
        # A private key that is used during authentication will be added to
        # ssh-agent if it is running
        addKeysToAgent = "yes";
        # Allow to securely use local SSH agent to authenticate on the remote
        # machine. It has the same effect as adding cli option `ssh -A user@host`
        forwardAgent = true;
      };
      "*.tailba6c3f.ts.net" = {
      };
      "ssh.github.com hf.co" = lib.hm.dag.entryBefore ["*.tailba6c3f.ts.net"] {
        user = "git";
        # identityFile = "~/sync_work/3keys/private/proteus_ed25519.key";
        # identitiesOnly = true; # Prevent sending default identity files first.
      };
      "desktop" = {
        hostname = "192.168.15.11";
        port = 22;
      };
      "192.168.*" = {
        # identityFile = "/etc/agenix/ssh-key-romantic"; # romantic holds my homelab~
        # identitiesOnly = true; # Specifies that ssh should only use the identity file. Required to prevent sending default identity files first.
      };
    };
  };
  programs.gpg = {
    publicKeys = [ # https://www.gnupg.org/gph/en/manual/x334.html
      {
        source = "${custom_files_dir}/proteus.pub.asc";
        trust = 5; # ultimate trust, my own keys
      }
    ];
  };
  programs.mpv.profiles.common.vulkan-device = "Intel(R) UHD Graphics (TGL GT1)";
  services.syncthing = {
    key = config.age.secrets."syncthing_proteus-nuc.key.pem".path;
    cert = "${custom_files_dir}/syncthing_proteus-nuc.crt.pem";
    settings = {
      devices = {
        "LGE-AN00".id = "T2V6DJB-243NJGD-5B63LUP-DSLNFBD-U72KGD2-AZVTIHL-HEUMBTI-HAVD7A2";
        "M2011K2C".id = "W6ZP2GU-HJ5DM7Q-UXKEKCI-OL3TYHM-LGLLPIN-3MCH7DM-76K3DB5-KNELIA5";
        "Proteus-MBP14M4P".id = "UF2KT6R-ISVDLBM-UJW3JKP-YZJTOES-7K55HS2-IGPE5MQ-OO4D6HK-LZRSLAE";
        "PROTEUSDESKTOP".id = "CLNAXLW-B2DBSV3-PDT246K-4CZQWGP-EE5MSB4-RUFYUKD-4ALXDXT-HZU3WAN";
        "Redmi Note 5".id = "V3BFX3M-H4RJSCS-DZ6XQIM-3T5JK2V-KPYKGPD-HUV5UMG-PQA52BH-MYOFIAR";
      };
      folders = {
        "work" = {
          path = "/srv/sync_work";
          devices = ["LGE-AN00" "M2011K2C" "Proteus-MBP14M4P" "PROTEUSDESKTOP" "Redmi Note 5"];
        };
        "nixos_configs_flake" = {
          path = "~/nixos_configs_flake";
          devices = ["Proteus-MBP14M4P"];
        };
        "sync" = {
          path = "~/sync";
          devices = ["PROTEUSDESKTOP"];
        };
      };
    };
  };
}
