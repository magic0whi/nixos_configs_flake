{pkgs, lib, config, myvars, nixpkgs-postgresql, docspell, ...}: let
  domain = "proteus.eu.org";
in {
  networking.firewall = let
    sunshine_port = config.services.sunshine.settings.port;
    s_https = builtins.toString (sunshine_port - 5); # Default: 47984 HTTPS
    s_http = builtins.toString sunshine_port; # Default: 47989 HTTP
    s_video = builtins.toString (sunshine_port + 9); # Default: 47998 UDP
    s_ctrl = builtins.toString (sunshine_port + 10); # Default: 47999 UDP
    s_audio = builtins.toString (sunshine_port + 11); # Default: 48000 UDP
    s_rtsp = builtins.toString (sunshine_port + 21); # Default: 48010 TCP
  in{
    allowedTCPPorts = [
      5201 # iperf3
      22000 # Syncthing TCP transfers
      53317 # LocalSend (HTTP/TCP)
      # Open Sunshine TCP ports
      (lib.strings.toInt s_https)
      (lib.strings.toInt s_http)
      (lib.strings.toInt s_rtsp)
    ];
    allowedUDPPorts = [
      5201 # iperf3
      21027 # Syncthing discovery broadcasts on IPv4 and multicasts on IPv6
      22000 # Syncthing QUIC transfers
      53317 # LocalSend (Multicast/UDP)
      # Open Sunshine UDP ports
      (lib.strings.toInt s_video)
      (lib.strings.toInt s_ctrl)
      (lib.strings.toInt s_audio)
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
        # Allow reverse proxy
        {client_ip_proxy_header = "X-Forwarded-For"; proxy_allowed = ["127.0.0.1"];}
        {address = "[::1]"; client_ip_proxy_header = "X-Forwarded-For"; proxy_allowed = ["::1"];}
      ];
      webdavd.bindings = [
        {port = 8443; client_ip_proxy_header = "X-Forwarded-For"; proxy_allowed = ["127.0.0.1"];}
        {address = "[::1]"; port = 8443; client_ip_proxy_header = "X-Forwarded-For"; proxy_allowed = ["::1"];}
      ];
    };
  };
  ## END services_sftpgo.nix
  ## START services_postgresql.nix
  age.secrets."postgresql_server.priv.pem" = {
    file = "${myvars.secrets_dir}/proteus_server.priv.pem.age";
    mode = "0400";
    owner = config.systemd.services.postgresql.serviceConfig.User;
  };
  # TODO: Learn SQL
  services.postgresql = {
    enable = true;
    package = nixpkgs-postgresql.legacyPackages.${pkgs.stdenv.hostPlatform.system}
      .postgresql.override {ldapSupport = true;};
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
      "docspell"
    ];
    ensureUsers = [
      {name = "proteus"; ensureClauses = {login = true; /*superuser = true;*/ createdb = true;};}
      {name = "atuin"; ensureDBOwnership = true;}
      {name = config.services.paperless.user; ensureDBOwnership = true;}
      {name = config.services.authelia.instances.main.user; ensureDBOwnership =true;}
      {name = "docspell"; ensureDBOwnership = true;}
    ];
    authentication = ''
      # type database DBuser auth-method [auth-options]
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
    database.uri = "postgres://atuin@postgresql.${domain}/atuin?sslmode=require";
    openRegistration = true;
  };
  ## END services_atuin.nix
  ## START services_immich.nix
  age.secrets."immich.env" = {file = "${myvars.secrets_dir}/immich.env.age"; mode = "0400"; owner = "root";};
  services.immich = {
    enable = true;
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
      PAPERLESS_WORKER_TIMEOUT = 300; # Default 1800 seconds (30min) is too long
      PAPERLESS_FILENAME_FORMAT = "{{ created_year }}/{{ correspondent }}/{{ document_type }}/{{ created }}_{{ title }}";
    };
    environmentFile = config.age.secrets."paperless.env".path;
    dataDir = "/srv/paperless";
    exporter.enable = true;
  };
  ## END services_paperless.nix
  ## START services_authelia.nix
  age.secrets = {
    "authelia_jwt_secret.txt" = {
      file = "${myvars.secrets_dir}/authelia_jwt_secret.txt.age";
      mode = "0400"; owner = config.services.authelia.instances.main.user;
    };
    "authelia_session_secret.txt" = {
      file = "${myvars.secrets_dir}/authelia_session_secret.txt.age";
      mode = "0400"; owner = config.services.authelia.instances.main.user;
    };
    "authelia_storage_encryption_key.txt" = {
      file = "${myvars.secrets_dir}/authelia_storage_encryption_key.txt.age";
      mode = "0400"; owner = config.services.authelia.instances.main.user;
    };
    "authelia_ldap_password.txt" = {
      file = "${myvars.secrets_dir}/authelia_ldap_password.txt.age";
      mode = "0400"; owner = config.services.authelia.instances.main.user;
    };
    "authelia_db_password.txt" = {
      file = "${myvars.secrets_dir}/authelia_db_password.txt.age";
      mode = "0400"; owner = config.services.authelia.instances.main.user;
    };
    "authelia_oidc_hmac.txt" = {
      file = "${myvars.secrets_dir}/authelia_oidc_hmac.txt.age";
      mode = "0400"; owner = config.services.authelia.instances.main.user;
    };
    "authelia_oidc_rsa.pem" = {
      file = "${myvars.secrets_dir}/authelia_oidc_rsa.pem.age";
      mode = "0400"; owner = config.services.authelia.instances.main.user;
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
      oidcIssuerPrivateKeyFile = config.age.secrets."authelia_oidc_rsa.pem".path;
      oidcHmacSecretFile = config.age.secrets."authelia_oidc_hmac.txt".path;
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
      # TODO use real email
      notifier.filesystem.filename = "/var/lib/authelia-main/emails.txt";
      authentication_backend = {
        ldap = {
          implementation = "custom";
          address = "ldaps://openldap.${domain}:636";
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
      identity_providers = {
        oidc = {
          cors = {
            endpoints = ["authorization" "token" "revocation" "introspection" "userinfo"];
            allowed_origins = ["https://docspell.${domain}"];
          };
          clients = [{
            client_id = "docspell";
            client_name = "Docspell";
            client_secret = "$pbkdf2-sha512$310000$60.rKB0d1SCVlF6.bY8njg$EDUxCscYZn1T2B1DPkY8L.WZ.kHI7dxZUFMLcDOaAJjkrc/4wABUnYHvXqNLZ.AFQIIpGRXeyZI2auFE.uwxWw";
            public = false;
            authorization_policy = "two_factor"; # Require 2FA for Docspell
            redirect_uris = [
              "https://docspell.${domain}/api/v1/open/auth/openid/authelia/resume"
            ];
            scopes = ["openid" "profile" "email" "groups"];
            response_modes = ["form_post" "query"];
            userinfo_signed_response_alg = "none";
            token_endpoint_auth_method = "client_secret_post";
          }];
        };
      };
    };
  };
  ## END services_authelia.nix
  ## START services_home_assistant.nix
  services.home-assistant = {
    enable = true;
    # NixOS will automatically fetch the required Python dependencies (like
    # python-miio) and assign Bluetooth capabilities for BLE sensors.
    extraComponents = [
      "default_config"
      "met" # Meteorologisk institutt (Met.no)
      "homekit" # xiaomi_miot requires pyhap
    ];
    # Include custom components if specific devices are better supported by the
    # community 'xiaomi_miot' integration.
    customComponents = with pkgs.home-assistant-custom-components; [
      xiaomi_miot # Xiaomi Miot Auto (Community)
      # xiaomi_home # Xiaomi Home (Official)
    ];
    config = {
      default_config = {}; # Implicitly enable `mobile_app`
      http = {
        server_port = 8123; server_host = ["127.0.0.1" "::1"];
        use_x_forwarded_for = true; trusted_proxies = ["127.0.0.1" "::1"];
        cors_allowed_origins = ["https://hass.${domain}"];
      };
      homeassistant = {
        name = "Proteus' Homo";
        unit_system = "metric"; # or "us_customary"
        latitude = config.home-manager.users.${myvars.username}.services.gammastep.settings.manual.lat;
        longitude = config.home-manager.users.${myvars.username}.services.gammastep.settings.manual.lon;
        time_zone = "Asia/Hong_Kong";
      };
      logger.default = "info";
    };
  };
  ## END services_home_assistant.nix
  ## STASRT sunshine.nix
  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    settings = {
      adapter_name = "/dev/dri/${myvars.dgpu_sym_name}";
      origin_web_ui_allowed = "pc";
    };
  };
  ## END sunshine.nix
  ## START docspell.nix
  nixpkgs.overlays = [docspell.overlays.default];
  age.secrets = {
    "docspell_db_password.txt" = {
      file = "${myvars.secrets_dir}/docspell_db_password.txt.age";
      mode = "0400"; owner = "docspell";
    };
    "docspell_jwt_secret.txt" = { # For auth.server-secret
      file = "${myvars.secrets_dir}/docspell_jwt_secret.txt.age";
      mode = "0400"; owner = "docspell";
    };
    "docspell_oidc_secret.txt" = {
      file = "${myvars.secrets_dir}/docspell_oidc_secret.txt.age";
      mode = "0400"; owner = "docspell";
    };
  };
  # Inject the age secrets into the systemd services as environment variables
  systemd.services.docspell-restserver.serviceConfig.LoadCredential = [
    "db_pass:${config.age.secrets."docspell_db_password.txt".path}"
    "jwt_secret:${config.age.secrets."docspell_jwt_secret.txt".path}"
    "oidc_secret:${config.age.secrets."docspell_oidc_secret.txt".path}"
  ];
  systemd.services.docspell-joex.serviceConfig.LoadCredential = [
    "db_pass:${config.age.secrets."docspell_db_password.txt".path}"
  ];
  # Because Docspell configuration supports HOCON env variable substitution, we
  # export the credentials to the environment for substitution in extraConfig.
  # Override systemd services to natively use the docspell user and avoid `su`
  # We use `jq` to safely inject the secrets into the JSON configuration at
  # runtime to handle any special characters securely.
  systemd.services.docspell-restserver = {
    serviceConfig.User = lib.mkForce "docspell";
    script = let
      cfg = config.services.docspell-restserver;
      args = builtins.concatStringsSep " " cfg.jvmArgs;
      baseConfigFile = if cfg.configFile == null
        then "/etc/docspell-restserver.conf"
        else "${cfg.configFile}";
      runtimeFile = "/var/docspell/restserver-runtime.json";
    in lib.mkForce ''
      export DOCSPELL_DB_PASS="$(cat "$CREDENTIALS_DIRECTORY/db_pass")"
      export DOCSPELL_SERVER_SECRET="$(cat "$CREDENTIALS_DIRECTORY/jwt_secret")"
      export DOCSPELL_OIDC_SECRET="$(cat "$CREDENTIALS_DIRECTORY/oidc_secret")"

      ${lib.getExe pkgs.jq} --arg db_pass "$DOCSPELL_DB_PASS" \
         --arg jwt_secret "$DOCSPELL_SERVER_SECRET" \
         --arg oidc_secret "$DOCSPELL_OIDC_SECRET" \
         '.docspell.server.backend.jdbc.password = $db_pass |
          .docspell.server.auth."server-secret" = $jwt_secret |
          .docspell.server.openid[0].provider."client-secret" = $oidc_secret' \
         "${baseConfigFile}" > "${runtimeFile}"

      exec ${lib.getExe' cfg.package "docspell-restserver"} ${args} -- "${runtimeFile}"
    '';
  };
  systemd.services.docspell-joex = {
    serviceConfig.User = lib.mkForce "docspell";
    script = let
      cfg = config.services.docspell-joex;
      args = builtins.concatStringsSep " " cfg.jvmArgs;
      baseConfigFile = if cfg.configFile == null
        then "/etc/docspell-joex.conf"
        else "${cfg.configFile}";
      runtimeFile = "/var/docspell/joex-runtime.json";
    in lib.mkForce ''
      export DOCSPELL_DB_PASS="$(cat "$CREDENTIALS_DIRECTORY/db_pass")"

      ${lib.getExe pkgs.jq} --arg db_pass "$DOCSPELL_DB_PASS" \
         '.docspell.joex.jdbc.password = $db_pass' \
         "${baseConfigFile}" > "${runtimeFile}"

      exec ${lib.getExe' cfg.package "docspell-joex"} ${args} -- "${runtimeFile}"
    '';
  };
  services.docspell-restserver = {
    enable = true;
    base-url = "https://docspell.${domain}";
    bind.address = "127.0.0.1";
    internal-url = "http://${config.services.docspell-restserver.bind.address}:${builtins.toString config.services.docspell-restserver.bind.port}";
    full-text-search = {
      enabled = true;
      backend = "postgresql";
      postgresql.use-default-connection = true;
    };
    backend.jdbc = {
      url = "jdbc:postgresql://postgresql.${domain}:${builtins.toString config.services.postgresql.settings.port}/docspell?sslmode=require";
      user = "docspell";
      password = "OVERRIDDEN_BY_JVM_ARGS";
    };
    auth.server-secret = "OVERRIDDEN_BY_JVM_ARGS";
    openid = [{
      enabled = true;
      display = "Login via Authelia";
      user-key = "preferred_username";
      provider = {
        provider-id = "authelia";
        client-id = "docspell";
        client-secret = "OVERRIDDEN_BY_JVM_ARGS";
        # Use internal localhost HTTP endpoint to bypass EmberClient TLS/SSL requirement
        authorize-url = "https://auth.${domain}/api/oidc/authorization"; # Keep public for user redirect
        token-url = "http://127.0.0.1:9092/api/oidc/token"; # Internal for server-to-server
        user-url = "http://127.0.0.1:9092/api/oidc/userinfo"; # Internal for server-to-server
        logout-url = "https://auth.${domain}/logout";
        scope = "openid profile email";
      };
    }];
  };
  services.docspell-joex = {
    enable = true;
    base-url = "https://docspell.${domain}";
    bind.address = "127.0.0.1";
    full-text-search = {
      enabled = true;
      backend = "postgresql";
      postgresql.use-default-connection = true;
    };
    jdbc = {
      url = "jdbc:postgresql://postgresql.${domain}:${builtins.toString config.services.postgresql.settings.port}/docspell?sslmode=require";
      user = "docspell";
      password = "OVERRIDDEN_BY_JVM_ARGS";
    };
  };
  ## END docspell.nix
}
