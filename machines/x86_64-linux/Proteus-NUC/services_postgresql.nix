{
  myvars,
  config,
  pkgs,
  lib,
  # nixpkgs-postgresql,
  ...
}: {
  age.secrets."postgresql_server.priv.pem" = {
    file = "${myvars.secrets_dir}/proteus_server.priv.pem.age";
    mode = "0400"; owner = config.systemd.services.postgresql.serviceConfig.User;
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
      ssl_key_file = config.age.secrets."postgresql_server.priv.pem".path;
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
  systemd.tmpfiles.rules = lib.mkIf config.services.postgresqlBackup.enable [
    "z '${config.services.postgresqlBackup.location}' 2770 ${myvars.username} ${config.systemd.services.postgresql.serviceConfig.User} - -"
  ];
  systemd.services.postgresqlBackup.serviceConfig.ExecStartPost = [
    "+${pkgs.coreutils}/bin/chown -R ${myvars.username}:${config.services.paperless.user} ${config.services.postgresqlBackup.location}"
    "+${pkgs.coreutils}/bin/chmod -R u+rwX,g+rwX ${config.services.postgresqlBackup.location}"
  ];
}
