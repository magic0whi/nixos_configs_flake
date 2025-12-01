{myvars, config, ...}: {
  services.syncthing = {
    key = config.age.secrets."syncthing_proteus-nuc.priv.pem".path;
    cert = "${myvars.secrets_dir}/syncthing_proteus-nuc.crt.pem";
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
          path = "/srv/sync";
          devices = ["PROTEUSDESKTOP"];
        };
      };
    };
  };
}
