{
  myvars,
  config,
  lib,
  # mylib,
  ...
}: {
  ## START services_monero.nix
  services.monero = {
    enable = true;
    dataDir = "${myvars.storage_path}/monero";
    extraConfig = ''
      # log-file=${config.services.monero.dataDir}/monero.log
      # log-level=0
      p2p-use-ipv6=1
      rpc-use-ipv6=1
      public-node=1
      confirm-external-bind=1
      rpc-bind-ipv6-address=fd7a:115c:a1e0::d901:e013
    '';
    prune = true;
    rpc.address = myvars.networking.hosts_addr.Proteus-Desktop.ipv4;
    rpc.restricted = true;
  };
  ## END services_monero.nix
  ## START syncthing.nix
  sops.secrets."Proteus-Desktop_syncthing.priv.pem" = {
    sopsFile = "${myvars.secrets_dir}/Proteus-Desktop_syncthing.priv.pem.sops";
    format = "binary";
    restartUnits = ["syncthing.service"];
  };
  # If without `users.groups.storage` and rely on LDAP group
  # systemd.services.syncthing.serviceConfig.SupplementaryGroups = ["storage"];
  systemd.services.syncthing.unitConfig.RequiresMountsFor = [myvars.storage_path];
  services.syncthing = {
    enable = true;
    group = "storage"; # Don't work for a LDAP group
    key = config.sops.secrets."Proteus-Desktop_syncthing.priv.pem".path;
    cert = "${myvars.secrets_dir}/Proteus-Desktop_syncthing.pub.pem";
    settings = let
      mobile_devices = {
        "LGE-AN00".id = "T2V6DJB-243NJGD-5B63LUP-DSLNFBD-U72KGD2-AZVTIHL-HEUMBTI-HAVD7A2";
        "M2011K2C".id = "W6ZP2GU-HJ5DM7Q-UXKEKCI-OL3TYHM-LGLLPIN-3MCH7DM-76K3DB5-KNELIA5";
        "Redmi Note 5".id = "V3BFX3M-H4RJSCS-DZ6XQIM-3T5JK2V-KPYKGPD-HUV5UMG-PQA52BH-MYOFIAR";
      };
    in {
      devices = builtins.mapAttrs (n: v: {id = v.syncthing_id;}) (
        lib.attrsets.filterAttrs # Filter out self
          (n: v: v ? syncthing_id && n != config.networking.hostName)
          myvars.networking.known_hosts)
      // mobile_devices;

      folders = {
        "Documents" = {
          path = "${myvars.storage_path}/share/Documents";
          # All devices
          devices = builtins.attrNames config.services.syncthing.settings.devices;
        };
        "Games" = {
          path = "${myvars.storage_path}/share/Games";
          devices = lib.lists.subtractLists
            (builtins.attrNames mobile_devices)
            (builtins.attrNames config.services.syncthing.settings.devices);
        };
        "Music" = {
          path = "${myvars.storage_path}/share/Music";
          devices = builtins.attrNames config.services.syncthing.settings.devices;
        };
        "Pictures" = {
          path = "${myvars.storage_path}/share/Pictures";
          devices = builtins.attrNames config.services.syncthing.settings.devices;
        };
        "Secrets" = {
          path = "${myvars.storage_path}/share/Secrets";
          devices = lib.lists.subtractLists
            (builtins.attrNames mobile_devices)
            (builtins.attrNames config.services.syncthing.settings.devices);
        };
        "Works" = {
          path = "${myvars.storage_path}/share/Works";
          devices = lib.lists.subtractLists
            (builtins.attrNames mobile_devices)
            (builtins.attrNames config.services.syncthing.settings.devices);
        };
      };
    };
  };
  ## END syncthing.nix
  ## BEGIN minio.nix
  nixpkgs.config.permittedInsecurePackages = ["minio-2025-10-15T17-29-55Z"];
  age.secrets."minio.env" = {
    file = "${myvars.secrets_dir}/minio.env.age";
    mode = "0400"; owner = config.systemd.services.minio.serviceConfig.User;
  };
  systemd.services.minio.unitConfig.RequiresMountsFor = [myvars.storage_path];
  services.minio = {
    enable = true;
    listenAddress = "127.0.0.1:9000";
    consoleAddress = "127.0.0.1:9001";
    region = "cn-east1-a";
    dataDir = ["${myvars.storage_path}/minio"];
    rootCredentialsFile = config.age.secrets."minio.env".path;
  };
  ## END minio.nix
}
