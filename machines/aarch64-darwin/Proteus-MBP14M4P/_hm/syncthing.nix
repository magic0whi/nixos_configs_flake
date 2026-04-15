{myvars, config, lib, osConfig, ...}: {
  age.secrets."syncthing_Proteus-MBP14M4P.priv.pem" = {
    file = "${myvars.secrets_dir}/syncthing_Proteus-MBP14M4P.priv.pem.age";
    mode = "0500";
  };
  services.syncthing = {
    key = config.age.secrets."syncthing_Proteus-MBP14M4P.priv.pem".path;
    cert = "${myvars.secrets_dir}/syncthing_Proteus-MBP14M4P.crt.pem";
    settings = let
      mobile_devices = {
        "LGE-AN00".id = "T2V6DJB-243NJGD-5B63LUP-DSLNFBD-U72KGD2-AZVTIHL-HEUMBTI-HAVD7A2";
        "M2011K2C".id = "W6ZP2GU-HJ5DM7Q-UXKEKCI-OL3TYHM-LGLLPIN-3MCH7DM-76K3DB5-KNELIA5";
        "Redmi Note 5".id = "V3BFX3M-H4RJSCS-DZ6XQIM-3T5JK2V-KPYKGPD-HUV5UMG-PQA52BH-MYOFIAR";
      };
    in {
      devices = builtins.mapAttrs (n: v: {id = v.syncthing_id;}) (
        lib.attrsets.filterAttrs # Filter out self
          (n: v: v ? syncthing_id && n != osConfig.networking.hostName)
          myvars.networking.known_hosts)
      // mobile_devices;

      folders = {
        "Documents" = {
          path = config.xdg.userDirs.documents;
          # All devices
          devices = builtins.attrNames config.services.syncthing.settings.devices;
        };
        "Games" = {
          path = "${config.home.homeDirectory}/Games";
          devices = lib.lists.subtractLists
            (builtins.attrNames mobile_devices)
            (builtins.attrNames config.services.syncthing.settings.devices);
        };
        "Music" = {
          path = config.xdg.userDirs.music;
          devices = builtins.attrNames config.services.syncthing.settings.devices;
        };
        "Pictures" = {
          path = config.xdg.userDirs.pictures;
          devices = builtins.attrNames config.services.syncthing.settings.devices;
        };
        "Secrets" = {
          path = "${config.home.homeDirectory}/Secrets";
          devices = lib.lists.subtractLists
            (builtins.attrNames mobile_devices)
            (builtins.attrNames config.services.syncthing.settings.devices);
        };
        "Works" = {
          path = "${config.home.homeDirectory}/Works";
          devices = lib.lists.subtractLists
            (builtins.attrNames mobile_devices)
            (builtins.attrNames config.services.syncthing.settings.devices);
        };
      };
    };
  };
}
