## Setup a Nix binary cache server
# Get node id: `sudo garage node id`
# Input rpc secret: `export GARAGE_RPC_SECRET=$(systemd-ask-password)`
# Initialize single-node layout: `-h <full-node-id>@127.0.0.1:3901 layout assign -z cn-east1-a -c 200G <node-ids>`
# Commit layout: `garage -h <full-node-id>@127.0.0.1:3901 layout apply --version 1`
# Create the bucket: `garage -h <full-node-id>@127.0.0.1:3901 bucket create nix-cache`
# Create the access key: `garage -h <full-node-id>@127.0.0.1:3901 key create nixbuilder`
# Allow the key to access the bucket:
# `garage -h <full-node-id>@127.0.0.1:3901 bucket allow --read --write nix-cache --owner --key nixbuilder`
# Allow bucket-as-website bucket-as-website: garage -h <full-node-id>@127.0.0.1:3901 bucket website --allow nix-cache
{myvars, config, pkgs, lib, ...}: {
  sops = let
    restartUnits = ["garage.service"];
    sopsFile = "${myvars.secrets_dir}/Proteus-Desktop.sops.yaml";
  in {
    secrets = {
      "garage_rpc_secret" = {inherit restartUnits sopsFile;};
      "garage_admin_token" = {inherit restartUnits sopsFile;};
    };
    templates."garage.env" = {
      inherit restartUnits;
      content = ''
        GARAGE_RPC_SECRET=${config.sops.placeholder.garage_rpc_secret}
        GARAGE_ADMIN_TOKEN=${config.sops.placeholder.garage_admin_token}
        # TODO: For Prometheus
        # GARAGE_METRICS_TOKEN=
      '';
    };
    templates."garage-webui.env" = {
      restartUnits = ["garage-webui.service"]; content = "API_ADMIN_KEY=${config.sops.placeholder.garage_admin_token}";
    };
  };
  # systemd.tmpfiles.settings."10-garage-create-dir" = {"${myvars.storage_path}/garage/data".d = {group = "storage"; mode = "2775";};};
  systemd.services.garage = {
    unitConfig.RequiresMountsFor = [myvars.storage_path];
    serviceConfig = {EnvironmentFile = config.sops.templates."garage.env".path; SupplementaryGroups = ["storage"];};
  };
  services.garage = {
    enable = true;
    package = pkgs.garage_2;
    settings = {
      # metadata_dir = "${myvars.storage_path}/garage/meta"; # Garage recommends placing metadata on SSD
      data_dir = "${myvars.storage_path}/garage/data";
      rpc_bind_addr = "127.0.0.1:3901";
      rpc_public_addr = "127.0.0.1:3901";
      s3_api = { # s3_api (3900) is for common access
        api_bind_addr = "127.0.0.1:3900"; root_domain = ".s3-garage.${myvars.domain}"; s3_region = "cn-east1-a";
      };
      # s3_web (3902) is for bucket-as-website
      s3_web = {bind_addr = "127.0.0.1:3902"; root_domain = ".s3-garage-web.${myvars.domain}";};
      # admin (3903) is for webui access
      admin = {api_bind_addr = "127.0.0.1:3903";};

      replication_factor = 1;
    };
  };
  systemd.services.garage-webui = {
    description = "Garage Web UI";
    after = ["network.target" "network-online.target"];
    wants = ["network.target" "network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = lib.getExe pkgs.garage-webui;
      Restart = "on-failure";
      EnvironmentFile = config.sops.templates."garage-webui.env".path;
      Environment = [
        "PORT=3909" "CONFIG_PATH=${(pkgs.formats.toml {}).generate "config.toml" config.services.garage.settings}"
      ];
    };
  };
}
