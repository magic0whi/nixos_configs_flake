{
  myvars,
  config,
  lib,
  pkgs,
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
  age.secrets."syncthing_proteus-desktop.priv.pem" = {
    file = "${myvars.secrets_dir}/syncthing_proteus-desktop.priv.pem.age";
    mode = "0500"; owner = config.services.syncthing.user;
  };
  # If without `users.groups.storage` and rely on LDAP group
  # systemd.services.syncthing.serviceConfig.SupplementaryGroups = ["storage"];
  services.syncthing = {
    enable = true;
    group = "storage"; # Don't work for a LDAP group
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
  ## START webdav.nix
  security.pam.services.webdav = {};
  services.webdav-server-rs = {
    enable = true;
    group = "storage";
    debug = true;
    # https://github.com/miquels/webdav-server-rs/blob/547602e78783935b4ddd038fb795366c9c476bcc/webdav-server.toml
    settings = {
      server.listen = ["127.0.0.1:4918" "[::1]:4918"];
      accounts = {
        auth-type = "htpasswd.default";
        # auth-type = "pam";
        # acct-type = "unix";
      };
      htpasswd.default.htpasswd = toString (pkgs.writeText "webdav.htpasswd" "${myvars.username}:$6$bk8n5IqElcXC8PM2$U8ej4dXiJ2LpejhIEv/xv3kL0j5Fq6o4hm6Y.ygxnl4P33nrtYz/MdvmhAz12gdWFvPGbE30V0qsff1lQcVpb1");
      pam.service = "webdav";
      location = [{
        route = ["/*path"]; # `path` is a keyword
        directory = "${myvars.storage_path}/share";
        handler = "filesystem";
        methods = ["webdav-rw"];
        autoindex = true;
        auth = "true";
        hide-symlinks = true;
        # setuid = true;
      }];
    };
  };
  ## END webdav.nix
  ## START minio.nix
  age.secrets."minio.env" = {
    file = "${myvars.secrets_dir}/minio.env.age";
    mode = "0500"; owner = config.systemd.services.minio.serviceConfig.User;
  };
  systemd.services.minio.after = ["mnt-storage-data.mount"];
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
