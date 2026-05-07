{config, myvars, ...}: {
  sops = let restartUnits = ["atuin.service"]; in {
    secrets.atuin_db_password = {inherit restartUnits; sopsFile = "${myvars.secrets_dir}/Proteus-NUC.sops.yaml";};
    templates."atuin.env" = {
      inherit restartUnits;
      content = "ATUIN_DB_URI='postgres://atuin:${config.sops.placeholder.atuin_db_password}@postgresql.${myvars.domain}/atuin?sslmode=require'";
    };
  };
  services.atuin = {enable = true; environmentFile = config.sops.templates."atuin.env".path; openRegistration = true;};
}
