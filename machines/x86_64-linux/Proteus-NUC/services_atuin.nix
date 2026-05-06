{config, myvars, ...}: {
  sops.secrets.atuin_db_password = {
    sopsFile = "${myvars.secrets_dir}/Proteus-NUC.sops.yaml"; restartUnits = ["atuin.service"];
  };
  sops.templates."atuin.env" = {
    content = "ATUIN_DB_URI='postgres://atuin:${config.sops.placeholder.atuin_db_password}@postgresql.${myvars.domain}/atuin?sslmode=require'";
    restartUnits = ["atuin.service"];
  };
  services.atuin = {enable = true; environmentFile = config.sops.templates."atuin.env".path; openRegistration = true;};
}
