{
  myvars,
  config,
  pkgs,
  lib,
  # nixpkgs-postgresql,
  ...
}: {
  sops.secrets."postgresql_server.priv.pem" = {
    sopsFile = "${myvars.secrets_dir}/proteus_server.priv.pem.sops";
    format = "binary";
    owner = config.systemd.services.postgresql.serviceConfig.User;
    restartUnits = ["postgresql.service" "postgresql-setup.service"];
  };
  # TODO: Learn SQL
  services.postgresql = {
    enable = true;
    # package = nixpkgs-postgresql.legacyPackages.${
    #   pkgs.stdenv.hostPlatform.system
    # }.postgresql.override {ldapSupport = true;};
    package = pkgs.postgresql.override {ldapSupport = true;};
    enableJIT = true;
    enableTCPIP = true;
    settings = {
      ssl = true;
      ssl_cert_file = "${myvars.secrets_dir}/proteus_server.pub.pem";
      ssl_key_file = config.sops.secrets."postgresql_server.priv.pem".path;
    };
    ensureDatabases = [
      "mydatabase" # TODO: For learning
      "atuin"
      config.services.paperless.user
      config.services.authelia.instances.main.user
    ];
    ensureUsers = [
      {name = "proteus"; ensureClauses = {login = true; /*superuser = true;*/ createdb = true;};}
      {name = "atuin"; ensureDBOwnership = true;}
      {name = config.services.paperless.user; ensureDBOwnership = true;}
      {name = config.services.authelia.instances.main.user; ensureDBOwnership =true;}
    ];
    authentication = ''
      # type database DBuser auth-method [auth-options]
      local all all trust
      host all all 100.64.0.0/10 ldap ldapurl="ldaps://openldap.${myvars.domain}/ou=People,dc=tailba6c3f,dc=ts,dc=net?uid?sub"
      host all all fd7a:115c:a1e0::/48 ldap ldapurl="ldaps://openldap.${myvars.domain}/ou=People,dc=tailba6c3f,dc=ts,dc=net?uid?sub"
    '';
  };
  services.postgresqlBackup = {
    enable = true;
    # databases = ["docspell"];
    location = "/srv/Backups/psql";
    compression = "zstd";
    compressionLevel = 3;
  };
  systemd.tmpfiles.settings = let cfg = config.services.postgresqlBackup; in lib.mkIf cfg.enable {
    "10-postgresqlBackup-change-group".${cfg.location}.z = {mode = "2770"; group = "storage";};
  };
  systemd.services.postgresqlBackup.serviceConfig.ExecStartPost = [
    "+${pkgs.coreutils}/bin/chmod -R g+r ${config.services.postgresqlBackup.location}"
  ];
}
