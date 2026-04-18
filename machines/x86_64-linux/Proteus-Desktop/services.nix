{myvars, config, lib, pkgs, ...}: {
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
          path = "${myvars.storage_path}/Documents";
          # All devices
          devices = builtins.attrNames config.services.syncthing.settings.devices;
        };
        "Games" = {
          path = "${myvars.storage_path}/Games";
          devices = lib.lists.subtractLists
            (builtins.attrNames mobile_devices)
            (builtins.attrNames config.services.syncthing.settings.devices);
        };
        "Music" = {
          path = "${myvars.storage_path}/Music";
          devices = builtins.attrNames config.services.syncthing.settings.devices;
        };
        "Pictures" = {
          path = "${myvars.storage_path}/Pictures";
          devices = builtins.attrNames config.services.syncthing.settings.devices;
        };
        "Secrets" = {
          path = "${myvars.storage_path}/Secrets";
          devices = lib.lists.subtractLists
            (builtins.attrNames mobile_devices)
            (builtins.attrNames config.services.syncthing.settings.devices);
        };
        "Works" = {
          path = "${myvars.storage_path}/Works";
          devices = lib.lists.subtractLists
            (builtins.attrNames mobile_devices)
            (builtins.attrNames config.services.syncthing.settings.devices);
        };
      };
    };
  };
  ## END syncthing.nix
  ## START webdav.nix
  services.webdav = {
    enable = true;
    package = pkgs.dufs;
    # https://github.com/sigoden/dufs/tree/v0.45.0?tab=readme-ov-file#configuration-file
    settings = {
      serve-path = myvars.storage_path;
      bind = "127.0.0.1";
      hidden = ["tmp" "*.log" "*.lock"];
      port = 5000;
      # `:`to separate the username and password
      # `@` to separate the account and paths
      # `,` to separate paths
      #  suffix `:rw`/`:ro` set permissions
      auth = [
        "${myvars.username}:$6$JXjsG/C9M.vh0viR$7nTJDOpisqjjtRLMCDktrJp8zYSQuwgP34ZRdD2UXll31XHqi1nqIX2.hLCC9EX2lM0vq92v5G0W0m68TQdaf/@/:ro"
      ];
      allow-all = true; # Allow all operations
      allow-upload = true;
      allow-delete = true;
      allow-search = true;
      allow-symlink = true; # Allow symlink to files/folders outside root directory
      allow-archive = true; # Allow download folders as archive file
      allow-hash = true; # Allow `?hash` query to get file sha256 hash
      enable-cors = true; # Sets `Access-Control-Allow-Origin: *`
      render-try-index = true; # Serve index.html when requesting a directory, returns directory listing if not found index.html
      render-spa = true; # Serve SPA(Single Page Application)
      # assets = "<path>" # Set the path to the assets directory for overriding the built-in assets
      log-format = "$remote_addr $$http_X_FORWARDED_FOR $remote_user \"$request\" $status";
      compress = "low"; # Set zip compress level [default: low] [possible values: none, low, medium, high]
    };
  };
  ## END webdav.nix
  ## START minio.nix
  age.secrets."minio.env" = {
    file = "${myvars.secrets_dir}/minio.env.age";
    mode = "0500"; owner = config.systemd.services.minio.serviceConfig.User;
  };
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
