{myvars, config, ...}: {
  sops = let
    sopsFile = "${myvars.secrets_dir}/Proteus-NUC.sops.yaml";
    restartUnits = ["immich-machine-learning.service" "immich-server.service"];
  in {
    secrets = {
      immich_db_password = {inherit sopsFile restartUnits;};
      immich_oauth_secret = {inherit sopsFile restartUnits; owner = config.services.immich.user;};
    };
    templates."immich.env" = {
      inherit restartUnits; content = "DB_PASSWORD=${config.sops.placeholder.immich_db_password}";
    };
  };
  services.immich = {
    enable = true;
    host = "127.0.0.1";
    database.host = "postgresql.${myvars.domain}";
    secretsFile = config.sops.templates."immich.env".path;
    mediaLocation = "/srv/immich";
    settings = { # https://immich.proteus.eu.org/admin/system-settings?isOpen=authentication -> Export as JSON
      server.externalDomain = "https://immich.${myvars.domain}";
      oauth = {
        enabled = true;
        issuerUrl = "https://auth.${myvars.domain}";
        clientId = "immich";
        # NixOS will dynamically inject the contents of this file at runtime through `utils.genJqSecretsReplacement`
        clientSecret._secret = config.sops.secrets."immich_oauth_secret".path;
        autoLaunch = true;
      };
    };
  };
}
