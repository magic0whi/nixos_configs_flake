{pkgs, lib, config, myvars, ...}: let
  server_pub_crt = "${myvars.secrets_dir}/proteus_server.pub.pem";
  server_priv_crt_base = {file = "${myvars.secrets_dir}/proteus_server.priv.pem.age"; mode = "0400";};
  # server_priv_crt_proteus = config.age.secrets."proteus_server.priv.pem".path;
  domain = "proteus.eu.org";
in {
  age.secrets."proteus_server.priv.pem" = server_priv_crt_base // {owner = myvars.username;};
  networking.firewall = {
    allowedTCPPorts = [
      53 # unbound TCP
      443 # Traefik
      636 # OpenLDAP (secure)
      853 # unbound DoT
      5201 # iperf3
      22000 # Syncthing TCP transfers
      53317 # LocalSend (HTTP/TCP)
    ];
    allowedUDPPorts = [
      53 # unbound
      443 # Traefik (QUIC)
      # 636 # OpenLDAP (secure, generally not used)
      853 # unbound DNS-over-QUIC
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
      httpd.bindings = [{
        # address = "0.0.0.0";
        client_ip_proxy_header = "X-Forwarded-For";
        proxy_allowed = ["127.0.0.1"];
        # enable_https = true;
        # certificate_file = server_pub_crt;
        # certificate_key_file = server_priv_crt_proteus;
      }];
      webdavd.bindings = [{
        # address = "0.0.0.0";
        port = 8443;
        client_ip_proxy_header = "X-Forwarded-For";
        proxy_allowed = ["127.0.0.1"];
        # enable_https = true;
        # certificate_file = server_pub_crt;
        # certificate_key_file = server_priv_crt_proteus;
      }];
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
  ## START services_unbound.nix
  age.secrets."unbound_server.priv.pem" = server_priv_crt_base // {owner = config.services.unbound.user;};
  services.resolved.settings.Resolve.Domains = "~${domain}";
  services.unbound = {
    enable = true;
    settings = {
      remote-control.control-enable = true;
      server = {
        log-local-actions = true;
        log-servfail = true;
        so-sndbuf = 0;
        interface = with myvars.networking.hosts_addr.Proteus-NUC; [
          "${ipv4}@53" "${ipv6}@53"
          "${ipv4}@853" "${ipv6}@853"
          "${ipv4}@9443" "${ipv6}@9443"
        ];
        tls-service-pem = server_pub_crt;
        tls-service-key = config.age.secrets."unbound_server.priv.pem".path;
        # https-port = 9443; # Unbound is not compiled with nghttp2
        hide-identity = true;
        hide-version = true;
        # Setting module-config to just "iterator" disables DNSSEC validation
        module-config = "iterator";
        access-control = [
          "127.0.0.0/8 allow" "::1/128 allow"
          "100.64.0.0/10 allow" "fd7a:115c:a1e0::/48 allow"
          "192.168.0.0/16 allow"
          # Best practice: explicitly refuse everything else
          "0.0.0.0/0 refuse"
          "::0/0 refuse"
        ];
        # Good practice: explicitly tell Unbound it is answering locally for
        # these reverse zones so it doesn't try to query the public root servers.
        local-zone = [
          "161.64.100.in-addr.arpa. nodefault"
          "0.e.1.a.c.5.1.1.a.7.d.f.ip6.arpa. nodefault"
        ];
      };
      auth-zone = [
        {name = "${domain}."; zonefile = "${myvars.secrets_dir}/${domain}.zone";}
        {name = "161.64.100.in-addr.arpa."; zonefile = "${myvars.secrets_dir}/161.64.100.in-addr.arpa.zone";}
        {
          name = "0.e.1.a.c.5.1.1.a.7.d.f.ip6.arpa.";
          zonefile = "${myvars.secrets_dir}/0.e.1.a.c.5.1.1.a.7.d.f.ip6.arpa.zone";
        }
      ];
    };
  };
  ## END services_unbound.nix
  ## START services_traefik.nix
  age.secrets."traefik_server.priv.pem" = server_priv_crt_base // {
    owner = config.systemd.services.traefik.serviceConfig.User;
  };
  services.traefik = {
    enable = true;
    # Static configuration handles entrypoints (ports) and global settings
    staticConfigOptions = {
      global = {checkNewVersion = false; sendAnonymousUsage = false;};
      api.dashboard = true;
      entryPoints = {
        # Force HTTP to HTTPS redirect globally
        web = {address = ":80"; http.redirections.entryPoint = {to = "websecure"; scheme = "https";};};
        websecure = {
          address = ":443";
          http3 = {}; # For QUIC
          # Prevent large video uploads from timing out and throwing Error 499.
          # Ref: https://web.archive.org/web/20260217103328/https://docs.immich.app/administration/reverse-proxy/#traefik-proxy-example-config
          transport.respondingTimeouts = {readTimeout = "600s"; idleTimeout = "600s";};
        };
        # Dedicated entrypoint for secure LDAP traffic
        ldaps = {address = ":636";};
      };
    };
    # Dynamic configuration defines routing rules, backend services, and certificate management.
    dynamicConfigOptions = {
      # tls.certificates = [{certFile = server_pub_crt; keyFile = config.age.secrets."traefik_server.priv.pem".path;}];

      # Establish the default fallback certificate.
      # This is critical for TCP clients (like `ldapsearch`) that do not send
      # Server Name Indication (SNI) data during the TLS handshake. Without this,
      # Traefik serves an untrusted dummy certificate.
      tls.stores.default.defaultCertificate = {
        certFile = server_pub_crt; keyFile = config.age.secrets."traefik_server.priv.pem".path;
      };
      http = {
        middlewares.authelia-auth.forwardAuth = {
          # Tell Traefik where to ask if a user is authenticated
          address = "http://127.0.0.1:9092/api/verify?rd=https://auth.${domain}/";
          trustForwardHeader = true;
          authResponseHeaders = ["Remote-User" "Remote-Groups" "Remote-Email" "Remote-Name"];
        };
        routers = {
          # Router for the login portal
          # `tls = {}` enables TLS using the default cert provided above
          authelia = {
            rule = "Host(`auth.${domain}`)";
            entryPoints = ["websecure"];
            service = "authelia-backend";
            tls = {};
          };
          traefik-dashboard = {
            rule = "Host(`traefik.${domain}`)";
            entryPoints = ["websecure"];
            # Protect the dashboard
            middlewares = ["authelia-auth"]; 
            service = "api@internal";
            tls = {};
          };
          atuin = {rule = "Host(`atuin.${domain}`)"; entryPoints = ["websecure"]; service = "atuin"; tls = {};};
          immich = {rule = "Host(`immich.${domain}`)"; entryPoints = ["websecure"]; service = "immich"; tls = {};};
          paperless = {
            rule = "Host(`paperless.${domain}`)"; entryPoints = ["websecure"]; service = "paperless"; tls = {};
          };
          sftpgo-webui = {
            rule = "Host(`sftpgo.${domain}`)"; entryPoints = ["websecure"]; service = "sftpgo-webui"; tls = {};
          };
          sftpgo-webdav = {
            rule = "Host(`webdav.${domain}`)"; entryPoints = ["websecure"]; service = "sftpgo-webdav"; tls = {};
          };
        };
        services = {
          authelia-backend.loadBalancer.servers = [{url = "http://127.0.0.1:9092";}];
          atuin.loadBalancer.servers = [{url = "http://127.0.0.1:${builtins.toString config.services.atuin.port}";}];
          immich.loadBalancer.servers = [{url = "http://127.0.0.1:${builtins.toString config.services.immich.port}";}];
          paperless.loadBalancer.servers = [{url = "http://127.0.0.1:${builtins.toString config.services.paperless.port}";}];
          sftpgo-webui.loadBalancer.servers = [
            {url = "http://127.0.0.1:${builtins.toString (builtins.head config.services.sftpgo.settings.httpd.bindings).port}";}
          ];
          sftpgo-webdav.loadBalancer.servers = [
            {url = "http://127.0.0.1:${builtins.toString (builtins.head config.services.sftpgo.settings.webdavd.bindings).port}";}
          ];
        };
      };
      tcp = {
        routers = {
          # Catch-all for traffic on this port. standard LDAP clients (like
          # ldapsearch and many older legacy systems) do not send SNI data.
          openldap-secure = {rule = "HostSNI(`*`)"; entryPoints = ["ldaps"]; service = "openldap-backend"; tls = {};};
        };
        # Instruct Traefik to inject the PROXY protocol v2 header
        services.openldap-backend.loadBalancer = {proxyProtocol.version = 2; servers = [{address = "127.0.0.1:389";}];};
      };
    };
  };
  ## END services_traefik.nix
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

      PAPERLESS_OCR_LANGUAGES = "chi-sim chi-tra";
      PAPERLESS_OCR_LANGUAGE = "chi_sim+chi_tra+eng";

      PAPERLESS_ADMIN_USER = myvars.username;
      PAPERLESS_USE_X_FORWARD_HOST = true;
      PAPERLESS_USE_X_FORWARD_PORT = true;
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
