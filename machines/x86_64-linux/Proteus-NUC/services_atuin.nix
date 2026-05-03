{config, myvars, lib, ...}: {
  age.secrets."atuin.env" = {file = "${myvars.secrets_dir}/atuin.env.age"; mode = "0400"; owner = "root";};
  systemd.services = lib.mkIf config.services.atuin.enable {
    atuin.serviceConfig.EnvironmentFile = config.age.secrets."atuin.env".path;
  };
  services.atuin = {
    enable = true;
    database.uri = "postgres://atuin@postgresql.${myvars.domain}/atuin?sslmode=require";
    openRegistration = true;
  };
}
