{myvars, config, lib, ...}: let
  storage_path = "/mnt/storage/data";
in {
  ## START services_monero.nix
  services.monero = {
    enable = true;
    dataDir = "/mnt/storage/data/monero";
    extraConfig = ''
      # log-file=/mnt/storage1/monero/monero.log
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
  age.secrets."syncthing_proteus-desktop.priv.pem" = {
    file = "${myvars.secrets_dir}/syncthing_proteus-desktop.priv.pem.age";
    mode = "0500"; owner = config.services.syncthing.user;
  };
  services.syncthing = {
    enable = true;
    group = "users";
    key = config.age.secrets."syncthing_proteus-desktop.priv.pem".path;
    cert = "${myvars.secrets_dir}/syncthing_proteus-desktop.crt.pem";
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
          path = "${storage_path}/Documents";
          # All devices
          devices = builtins.attrNames config.services.syncthing.settings.devices;
        };
        "Games" = {
          path = "${storage_path}/Games";
          devices = lib.lists.subtractLists
            (builtins.attrNames mobile_devices)
            (builtins.attrNames config.services.syncthing.settings.devices);
        };
        "Music" = {
          path = "${storage_path}/Music";
          devices = builtins.attrNames config.services.syncthing.settings.devices;
        };
        "Pictures" = {
          path = "${storage_path}/Pictures";
          devices = builtins.attrNames config.services.syncthing.settings.devices;
        };
        "Secrets" = {
          path = "${storage_path}/Secrets";
          devices = lib.lists.subtractLists
            (builtins.attrNames mobile_devices)
            (builtins.attrNames config.services.syncthing.settings.devices);
        };
        "Works" = {
          path = "${storage_path}/Works";
          devices = lib.lists.subtractLists
            (builtins.attrNames mobile_devices)
            (builtins.attrNames config.services.syncthing.settings.devices);
        };
      };
    };
  };
  ## END syncthing.nix
}
