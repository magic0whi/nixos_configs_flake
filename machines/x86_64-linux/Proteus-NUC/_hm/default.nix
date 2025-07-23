{agenix, config, lib, mylib, myvars, pkgs, ...}: let
  dpi_scale = lib.strings.substring 0 4 (lib.strings.floatToString 1.25);
  main_monitor = "eDP-1";
  modeline = "highres,auto,${dpi_scale},bitdepth,10";
  custom_files_dir = mylib.relative_to_root "custom_files";
in {
  home.packages = [pkgs.nvtopPackages.intel];
  modules.desktop.hyprland = {
    enable = true;
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
  };
  # modules.editors.emacs.enable = true;
  programs.ssh = {
    enable = true;
    forwardAgent = true; # Allow to securely use local SSH agent to authenticate on the remote machine. It has the same effect as adding cli option `ssh -A user@host`
    addKeysToAgent = "yes";  # A private key that is used during authentication will be added to ssh-agent if it is running
    matchBlocks = {
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
        source = mylib.relative_to_root "custom_files/proteus.pub.asc";
        trust = 5; # ultimate trust, my own keys
      }
    ];
  };
  programs.mpv.profiles.common.vulkan-device = "Intel(R) UHD Graphics (TGL GT1)";
  ## START secrets.nix
  imports = [agenix.homeManagerModules.default];
  age.identityPaths = ["/home/${myvars.username}/sync_work/3keys/private/legacy/proteus_ed25519.key"];
  age.secrets = let
    noaccess = {mode = "0000";};
    high_security = {mode = "0500";};
  in {
    "syncthing_proteus-nuc.key.pem" = {file = "${custom_files_dir}/syncthing_proteus-nuc.key.pem.age";} // high_security;
  };
  ## END secrets.nix
  services.syncthing = {
    key = config.age.secrets."syncthing_proteus-nuc.key.pem".path;
    cert = "${custom_files_dir}/syncthing_proteus-nuc.crt.pem";
    settings = {
      devices = {
        "LGE-AN00" = {id = "T2V6DJB-243NJGD-5B63LUP-DSLNFBD-U72KGD2-AZVTIHL-HEUMBTI-HAVD7A2";};
        "M2011K2C" = {id = "W6ZP2GU-HJ5DM7Q-UXKEKCI-OL3TYHM-LGLLPIN-3MCH7DM-76K3DB5-KNELIA5";};
        "Proteus-MBP14M4P" = {id = "UF2KT6R-ISVDLBM-UJW3JKP-YZJTOES-7K55HS2-IGPE5MQ-OO4D6HK-LZRSLAE";};
        "PROTEUSDESKTOP" = {id = "CLNAXLW-B2DBSV3-PDT246K-4CZQWGP-EE5MSB4-RUFYUKD-4ALXDXT-HZU3WAN";};
        "PROTEUSNOTEBOOK-WIN" = {id = "QAQHY4R-7KAQYI6-3WLUHMF-Y4LG5LR-XJMDYTF-3LUIOX3-VO33BCP-RBDM2A6";};
      };
      folders = {
        "work" = {
          path = "~/sync_work";
          devices = ["LGE-AN00" "M2011K2C" "Proteus-MBP14M4P" "PROTEUSDESKTOP" "PROTEUSNOTEBOOK-WIN"];
        };
        "nixos_configs_flake" = {
          path = "~/nixos_configs_flake";
          devices = ["Proteus-MBP14M4P"];
        };
      };
    };
  };
}
