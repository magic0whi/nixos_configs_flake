{pkgs, lib, config, myvars, ...}: let
  server_pub_crt = "${myvars.secrets_dir}/proteus_server.pub.pem";
  server_priv_crt_base = {file = "${myvars.secrets_dir}/proteus_server.priv.pem.age"; mode = "0400";};
  # server_priv_crt_proteus = config.age.secrets."proteus_server.priv.pem".path;
  domain = "proteus.eu.org";
in {
  networking.firewall = {
    allowedTCPPorts = [
      5201 # iperf3
      22000 # Syncthing TCP transfers
      53317 # LocalSend (HTTP/TCP)
    ];
    allowedUDPPorts = [
      5201 # iperf3
      21027 # Syncthing discovery broadcasts on IPv4 and multicasts on IPv6
      22000 # Syncthing QUIC transfers
      53317 # LocalSend (Multicast/UDP)
    ];
  };
  ## START tor.nix
  services.tor = {
    enable = true;
    client.enable = true;
    # openFirewall = true;
    settings = {
      # ExitNodes = "{GB}";
      ExitPolicy = ["accept *:*"];
      AvoidDiskWrites = 1;
      HardwareAccel = 1;
      UseBridges = true;
      ClientTransportPlugin = "snowflake exec ${lib.getExe' pkgs.snowflake "client"} -url https://snowflake-broker.azureedge.net/ -front ajax.aspnetcdn.com -ice stun:stun.l.google.com:19302,stun:stun.antisip.com:3478,stun:stun.bluesip.net:3478,stun:stun.dus.net:3478,stun:stun.epygi.com:3478,stun:stun.sonetel.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.voys.nl:3478 utls-imitate=hellorandomizedalpn -log /tmp/snowflake-client.log";
      Bridge = [
        "snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72 fingerprint=2B280B23E1107BB62ABFC40DDCC8824814F80A72 url=https://1098762253.rsc.cdn77.org/ fronts=www.cdn77.com,www.phpmyadmin.net ice=stun:stun.l.google.com:19302,stun:stun.antisip.com:3478,stun:stun.bluesip.net:3478,stun:stun.dus.net:3478,stun:stun.epygi.com:3478,stun:stun.sonetel.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.voys.nl:3478 utls-imitate=hellorandomizedalpn"
        "snowflake 192.0.2.4:80 8838024498816A039FCBBAB14E6F40A0843051FA fingerprint=8838024498816A039FCBBAB14E6F40A0843051FA url=https://1098762253.rsc.cdn77.org/ fronts=www.cdn77.com,www.phpmyadmin.net ice=stun:stun.l.google.com:19302,stun:stun.antisip.com:3478,stun:stun.bluesip.net:3478,stun:stun.dus.net:3478,stun:stun.epygi.com:3478,stun:stun.sonetel.net:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.voys.nl:3478 utls-imitate=hellorandomizedalpn"
      ];
    };
  };
  ## END tor.nix
  ## START services_sftpgo.nix
  services.sftpgo = {
    enable = true;
    user = myvars.username;
    group = myvars.username;
    extraReadWriteDirs = [/srv];
    settings = {
      httpd.bindings = [
        {
          # address = "0.0.0.0";
          client_ip_proxy_header = "X-Forwarded-For";
          proxy_allowed = ["127.0.0.1"];
          # enable_https = true;
          # certificate_file = server_pub_crt;
          # certificate_key_file = server_priv_crt_proteus;
        }
        {
          address = "[::1]";
          client_ip_proxy_header = "X-Forwarded-For";
          proxy_allowed = ["::1"];
          # enable_https = true;
          # certificate_file = server_pub_crt;
          # certificate_key_file = server_priv_crt_proteus;
        }
      ];
      webdavd.bindings = [
        {
          # address = "0.0.0.0";
          port = 8443;
          client_ip_proxy_header = "X-Forwarded-For";
          proxy_allowed = ["127.0.0.1"];
          # enable_https = true;
          # certificate_file = server_pub_crt;
          # certificate_key_file = server_priv_crt_proteus;
        }
        {
          address = "[::1]";
          port = 8443;
          client_ip_proxy_header = "X-Forwarded-For";
          proxy_allowed = ["::1"];
        }
      ];
    };
  };
  ## END services_sftpgo.nix
  ## START services_postgresql.nix
  age.secrets."postgresql_server.priv.pem" = server_priv_crt_base // {
    owner = config.systemd.services.postgresql.serviceConfig.User;
  };
  # TODO: Learn SQL
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql.override {ldapSupport = true;};
    enableJIT = true;
    enableTCPIP = true;
    settings = {
      ssl = true;
      ssl_cert_file = server_pub_crt;
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
      #type database DBuser auth-method [auth-options]
      local all all trust
      host all all 100.64.0.0/10 ldap ldapurl="ldaps://openldap.${domain}/ou=People,dc=tailba6c3f,dc=ts,dc=net?uid?sub"
      host all all fd7a:115c:a1e0::/48 ldap ldapurl="ldaps://openldap.${domain}/ou=People,dc=tailba6c3f,dc=ts,dc=net?uid?sub"
    '';
  };
  ## END services_postgresql.nix
  ## START services_atuin.nix
  age.secrets."atuin.env" = {file = "${myvars.secrets_dir}/atuin.env.age"; mode = "0400"; owner = "root";};
  systemd.services.atuin.serviceConfig.EnvironmentFile = config.age.secrets."atuin.env".path;
  services.atuin = {
    enable = true;
    # openFirewall = true;
    # host = "0.0.0.0";
    database.uri = "postgres://atuin@postgresql.${domain}/atuin?sslmode=require";
    openRegistration = true;
  };
  ## END services_atuin.nix
  ## START services_immich.nix
  age.secrets."immich.env" = {file = "${myvars.secrets_dir}/immich.env.age"; mode = "0400"; owner = "root";};
  services.immich = {
    enable = true;
    # openFirewall = true;
    host = "127.0.0.1";
    database.host = "postgresql.${domain}";
    secretsFile = config.age.secrets."immich.env".path;
    mediaLocation = "/srv/immich";
  };
  ## END services_immich.nix
  ## START services_paperless.nix
  age.secrets."paperless.env" = {file = "${myvars.secrets_dir}/paperless.env.age"; mode = "0400"; owner = "root";};
  services.paperless = {
    domain = "paperless.${domain}";
    enable = true;
    # address = "0.0.0.0";
    settings = {
      PAPERLESS_DBENGINE = "postgresql";
      PAPERLESS_DBHOST = "postgresql.${domain}";
      PAPERLESS_DBSSLMODE = "require";
      PAPERLESS_DBNAME = config.services.paperless.user;
      PAPERLESS_DBUSER = config.services.paperless.user;

      # https://tesseract-ocr.github.io/tessdoc/Data-Files-in-different-versions.html
      PAPERLESS_OCR_LANGUAGES = "chi-sim chi-tra";
      PAPERLESS_OCR_LANGUAGE = "chi_sim+chi_tra+eng";
      # https://dateparser.readthedocs.io/en/latest/supported_locales.html
      PAPERLESS_DATE_PARSER_LANGUAGES = "en+zh+zh-Hant";

      PAPERLESS_ADMIN_USER = myvars.username;
      PAPERLESS_USE_X_FORWARD_HOST = true;
      PAPERLESS_USE_X_FORWARD_PORT = true;

      APERLESS_WEBSERVER_WORKERS = 16;
      PAPERLESS_WORKER_TIMEOUT= 300; # Default 1800 seconds (30min) is too long
    };
    environmentFile = config.age.secrets."paperless.env".path;
    dataDir = "/srv/paperless";
  };
  ## END services_paperless.nix
  ## START services_authelia.nix
  age.secrets = {
    "authelia_jwt_secret.txt" = {
      file = "${myvars.secrets_dir}/authelia_jwt_secret.txt.age";
      mode = "0400";
      owner = config.services.authelia.instances.main.user;
    };
    "authelia_session_secret.txt" = {
      file = "${myvars.secrets_dir}/authelia_session_secret.txt.age";
      mode = "0400";
      owner = config.services.authelia.instances.main.user;
    };
    "authelia_storage_encryption_key.txt" = {
      file = "${myvars.secrets_dir}/authelia_storage_encryption_key.txt.age";
      mode = "0400";
      owner = config.services.authelia.instances.main.user;
    };
    "authelia_ldap_password.txt" = {
      file = "${myvars.secrets_dir}/authelia_ldap_password.txt.age";
      mode = "0400";
      owner = config.services.authelia.instances.main.user;
    };
    "authelia_db_password.txt" = {
      file = "${myvars.secrets_dir}/authelia_db_password.txt.age";
      mode = "0400";
      owner = config.services.authelia.instances.main.user;
    };
  };
  services.authelia.instances.main = {
    enable = true;
    secrets = {
      # To generate, run
      # nix run nixpkgs#authelia -- crypto rand --length 64 session_secret.txt storage_encryption_key.txt jwt_secret.txt
      jwtSecretFile = config.age.secrets."authelia_jwt_secret.txt".path;
      sessionSecretFile = config.age.secrets."authelia_session_secret.txt".path;
      storageEncryptionKeyFile = config.age.secrets."authelia_storage_encryption_key.txt".path;
    };
    # LDAP Password Injection
    # Using the _FILE suffix tells Authelia to read the contents of the secret path
    environmentVariables = {
      # Render to `settings.authentication_backend.ldap.password`
      AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = config.age.secrets."authelia_ldap_password.txt".path;
      # Render to `settings.storage.postgres.password`
      AUTHELIA_STORAGE_POSTGRES_PASSWORD_FILE = config.age.secrets."authelia_db_password.txt".path;
    };
    settings = {
      theme = "dark";
      default_2fa_method = "totp";
      # Use the new server.address syntax required by the module
      server.address = "tcp://127.0.0.1:9092";
      # This allows the login cookie to work across all your subdomains
      session.cookies = [{
        inherit domain;
        authelia_url = "https://auth.${domain}";
        same_site = "lax";
        inactivity = "5 minutes";
        expiration = "1 hour";
        remember_me = "1 month";
      }];
      storage.postgres = {
        address = "tcp://postgresql.${domain}:${builtins.toString config.services.postgresql.settings.port}";
        database = config.services.authelia.instances.main.user;
        schema = "public";
        username = config.services.authelia.instances.main.user;
        # Password is injected via environment variable
      };
      notifier.filesystem.filename = "/var/lib/authelia-main/emails.txt";
      authentication_backend = {
        ldap = {
          implementation = "custom";
          url = "ldaps://openldap.${domain}:636";
          timeout = "5s";
          base_dn = "dc=tailba6c3f,dc=ts,dc=net";
          additional_users_dn = "ou=People";
          users_filter = "(&({username_attribute}={input})(objectClass=person))";
          additional_groups_dn = "ou=Group";
          groups_filter = "(member={dn})";
          user = "cn=Manager,dc=tailba6c3f,dc=ts,dc=net";
          # Password is injected via environment variable
        };
      };
      access_control = {default_policy = "deny"; rules = [{domain = "*.${domain}"; policy = "one_factor";}];};
    };
  };
  ## END services_authelia.nix
}
