{myvars, config, ...}: {
  launchd.agents.syncthing.config = {
    StandardErrorPath = "/Users/${myvars.username}/Library/Logs/syncthing/stderr";
    StandardOutPath = "/Users/${myvars.username}/Library/Logs/syncthing/stdout";
  };
  services.syncthing = {
    key = config.age.secrets."syncthing_Proteus-MBP14M4P.priv.pem".path;
    cert = "${myvars.secrets_dir}/syncthing_Proteus-MBP14M4P.crt.pem";
    settings = {
      devices = {
        "LGE-AN00".id = "T2V6DJB-243NJGD-5B63LUP-DSLNFBD-U72KGD2-AZVTIHL-HEUMBTI-HAVD7A2";
        "M2011K2C".id = "W6ZP2GU-HJ5DM7Q-UXKEKCI-OL3TYHM-LGLLPIN-3MCH7DM-76K3DB5-KNELIA5";
        "Proteus-Desktop".id = "DFKVKXA-MHOUCDP-2DXEZGE-VUGGQXP-MRQCOZL-BOOBXAV-4IDSU26-B3GOUAF";
        "Proteus-NUC".id = "3P2RWV6-RQMHBFS-L3Z5JTF-O6HOR66-7INJZNM-XW3WUSG-XCIB454-UITNPAF";
        "Redmi Note 5".id = "V3BFX3M-H4RJSCS-DZ6XQIM-3T5JK2V-KPYKGPD-HUV5UMG-PQA52BH-MYOFIAR";
      };
      folders = {
        "work" = {
          path = "~/sync_work";
          devices = ["LGE-AN00" "M2011K2C" "Proteus-Desktop" "Proteus-NUC" "Redmi Note 5"];
        };
        "nixos_configs_flake" = {
          path = "~/nixos_configs_flake";
          devices = ["Proteus-NUC"];
        };
      };
    };
  };
}
