{lib, ...}: {
  modules.desktop = {
    hyprland = {
      enable = true;
      settings = {
        # Configure your Display resolution, offset, scale and Monitors here, use `hyprctl monitors` to get the info.
        #   highres:      get the best possible resolution
        #   auto:         position automatically
        #   1.5:          scale to 1.5 times
        #   bitdepth,10:  enable 10 bit support
        monitor = "eDP-1,highres,auto,1.5,bitdepth,10";
      };
    };
  };
  # modules.editors.emacs = {
    # enable = true;
  # };

  programs.ssh = {
    enable = true;
    forwardAgent = true; # allow to securely use local SSH agent to authenticate on the remote machine. It has the same effect as adding cli option `ssh -A user@host`
    addKeysToAgent = "yes";  # a private key that is used during authentication will be added to ssh-agent if it is running
    matchBlocks = {
      "*.tailba6c3f.ts.net" = {
        identityFile = "~/sync-work/3keys/private/proteus_ed25519.key";
      };
      "ssh.github.com hf.co" = lib.hm.dag.entryBefore ["*.tailba6c3f.ts.net"] {
        user = "git";
        identityFile = "~/sync-work/3keys/private/proteus_ed25519.key";
        identitiesOnly = true; # Required to prevent sending default identity files first.
      };
      "desktop" = {
        hostname = "192.168.15.11";
        port = 22;
      };
      "192.168.*" = {
        identityFile = "/etc/agenix/ssh-key-romantic"; # romantic holds my homelab~
        identitiesOnly = true; # Specifies that ssh should only use the identity file. Required to prevent sending default identity files first.
      };
    };
  };
  services.syncthing = {
    key = "${./syncthing_key.pem}";
    cert = "${./syncthing_cert.pem}";
    settings = {
      devices = {
        "LGE-AN00" = { id = "T2V6DJB-243NJGD-5B63LUP-DSLNFBD-U72KGD2-AZVTIHL-HEUMBTI-HAVD7A2"; };
        "M2011K2C" = { id = "M3HVW3S-OC32FV6-AHQ7JVU-KY7DQQ4-VF57UYZ-NCJCTU4-M2OXF4H-CY3HYAS"; };
        "PROTEUSDESKTOP" = { id = "CLNAXLW-B2DBSV3-PDT246K-4CZQWGP-EE5MSB4-RUFYUKD-4ALXDXT-HZU3WAN"; };
        "PROTEUSNOTEBOOK-WIN" = { id = "QAQHY4R-7KAQYI6-3WLUHMF-Y4LG5LR-XJMDYTF-3LUIOX3-VO33BCP-RBDM2A6"; };
      };
      folders = {
        "sync-work" = {
          path = "~/sync-work";
          devices = [ "LGE-AN00" "M2011K2C" "PROTEUSDESKTOP" "PROTEUSNOTEBOOK-WIN" ];
        };
      };
    };
  };
}
