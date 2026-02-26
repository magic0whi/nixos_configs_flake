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
      853 # unbound DoT
      5201 # iperf3
      22000 # Syncthing TCP transfers
      53317 # LocalSend (HTTP/TCP)
    ];
    allowedUDPPorts = [
      53 # unbound
      # 853 # unbound DNS-over-QUIC, bind don't support it
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
  # age.secrets."unbound_server.priv.pem" = server_priv_crt_base // {owner = config.services.unbound.user;};
  # services.unbound = {
  #   enable = true;
  #   settings = {
  #     remote-control.control-enable = true;
  #     server = {
  #       log-local-actions = true;
  #       log-servfail = true;
  #       so-sndbuf = 0;
  #       interface = with myvars.networking.hosts_addr.Proteus-NUC; [
  #         "${ipv4}@53" "${ipv6}@53"
  #         "${ipv4}@853" "${ipv6}@853"
  #         "${ipv4}@9443" "${ipv6}@9443"
  #       ];
  #       tls-service-pem = server_pub_crt;
  #       tls-service-key = config.age.secrets."unbound_server.priv.pem".path;
  #       # https-port = 9443; # Unbound is not compiled with nghttp2
  #       hide-identity = true;
  #       hide-version = true;
  #       # Setting module-config to just "iterator" disables DNSSEC validation
  #       module-config = "iterator";
  #       access-control = [
  #         "127.0.0.0/8 allow" "::1/128 allow"
  #         "100.64.0.0/10 allow" "fd7a:115c:a1e0::/48 allow"
  #         "192.168.0.0/16 allow"
  #         # Best practice: explicitly refuse everything else
  #         "0.0.0.0/0 refuse"
  #         "::0/0 refuse"
  #       ];
  #       # Good practice: explicitly tell Unbound it is answering locally for
  #       # these reverse zones so it doesn't try to query the public root servers.
  #       local-zone = [
  #         "161.64.100.in-addr.arpa. nodefault"
  #         "0.e.1.a.c.5.1.1.a.7.d.f.ip6.arpa. nodefault"
  #       ];
  #     };
  #     auth-zone = [
  #       {name = "${domain}."; zonefile = "${myvars.secrets_dir}/${domain}.zone";}
  #       {name = "161.64.100.in-addr.arpa."; zonefile = "${myvars.secrets_dir}/161.64.100.in-addr.arpa.zone";}
  #       {
  #         name = "0.e.1.a.c.5.1.1.a.7.d.f.ip6.arpa.";
  #         zonefile = "${myvars.secrets_dir}/0.e.1.a.c.5.1.1.a.7.d.f.ip6.arpa.zone";
  #       }
  #     ];
  #   };
  # };
  ## END services_unbound.nix
  ## START services_bind.nix
  # TODO: Nix Native Way for zonefile
  # Authoritative-only server for "proteus.eu.org"
  age.secrets."bind_server.priv.pem" = server_priv_crt_base // {
    owner = config.systemd.services.bind.serviceConfig.User;
  };
  # Append to the BIND preStart script
  systemd.services.bind.preStart = lib.mkAfter ''
    echo "Copying raw zone files from the secrets directory to the writable BIND directory..."
    install -m 0644 ${myvars.secrets_dir}/${domain}.zone ${config.services.bind.directory}/${domain}.zone
    install -m 0644 ${myvars.secrets_dir}/161.64.100.in-addr.arpa.zone ${config.services.bind.directory}/161.64.100.in-addr.arpa.zone
    install -m 0644 ${myvars.secrets_dir}/0.e.1.a.c.5.1.1.a.7.d.f.ip6.arpa.zone ${config.services.bind.directory}/0.e.1.a.c.5.1.1.a.7.d.f.ip6.arpa.zone
  '';
  services.resolved.settings.Resolve = {
    DNSSEC= "allow-downgrade";
    Domains = [
      "~proteus.eu.org" # The '~' prefix makes this a routing domain
      "~161.64.100.in-addr.arpa"
      "~0.e.1.a.c.5.1.1.a.7.d.f.ip6.arpa"
    ];
    DNS = ["100.64.161.20#proteus.eu.org"];
  };
  environment.etc."dnssec-trust-anchors.d/proteus.eu.org.positive".text = ''
    proteus.eu.org. IN DS 19905 15 2 ac53e45bd2ecd7e4d8ded050fb08e0f37095af97e0b6f73ce912a56ce5c542c0
  '';
  services.bind = {
    enable = true;
    # Persistent directory for DNSSEC key states.
    # NixOS defaults to /run/named, which clears on reboot.
    directory = "/srv/bind";
    # Access-control of what networks are allowed for recursive queries
    cacheNetworks = [];
    # cacheNetworks = [
    #   "127.0.0.0/8" "::1/128"
    #   "100.64.0.0/10" "fd7a:115c:a1e0::/48"
    #   "192.168.0.0/16"
    # ];
    forwarders = [];
    # Bind standard port 53 strictly to the specific interface IPs
    listenOn = [myvars.networking.hosts_addr.Proteus-NUC.ipv4];
    listenOnIpv6 = [myvars.networking.hosts_addr.Proteus-NUC.ipv6];

    # Inject the variables into the raw extraOptions string for DoT and DoH
    extraOptions = with myvars.networking.hosts_addr.Proteus-NUC; ''
      # Strictly Authoritative-Only Mode
      recursion no;
      # DNS-over-TLS (DoT) on port 853
      listen-on port 853 tls mycert { ${ipv4}; };
      listen-on-v6 port 853 tls mycert { ${ipv6}; };

      # DNS-over-HTTPS (DoH) on port 9443 using the default HTTP endpoint
      listen-on port 9443 tls mycert http default { ${ipv4}; };
      listen-on-v6 port 9443 tls mycert http default { ${ipv6}; };

      allow-transfer { none; };
      allow-update { none; };
      server-id none;

      # Disable global validation if relying solely on the trusted island
      dnssec-validation no;
    '';
    extraConfig = ''
      tls mycert {
        cert-file "${server_pub_crt}";
        key-file "${config.age.secrets."bind_server.priv.pem".path}";
      };
      # DNSSEC Trusted Island Policy
      dnssec-policy custom {
        keys {
          csk key-directory lifetime unlimited algorithm 15; # ED25519
        };
        max-zone-ttl 24h;
        signatures-refresh 8d; # Regenerate 8 days before expire
        signatures-validity 10d; # ZSK validity last for 10 days
        signatures-validity-dnskey 10d; # KSK validity last for 10 days
      };
    '';
    zones = {
      "${domain}" = {
        master = true;
        # file = "${myvars.secrets_dir}/${domain}.zone";
        file = "${domain}.zone"; # Relative path
        extraConfig = ''
          # Apply the DNSSEC policy to sign the zone locally
          dnssec-policy custom;
        '';
      };
      "161.64.100.in-addr.arpa" = {
        master = true;
        # file = "${myvars.secrets_dir}/161.64.100.in-addr.arpa.zone";
        file = "161.64.100.in-addr.arpa.zone"; # Relative path
      };
      "0.e.1.a.c.5.1.1.a.7.d.f.ip6.arpa" = {
        master = true;
        # file = "${myvars.secrets_dir}/0.e.1.a.c.5.1.1.a.7.d.f.ip6.arpa.zone";
        file = "0.e.1.a.c.5.1.1.a.7.d.f.ip6.arpa.zone"; # Relative path
      };
    };
  };
  ## END services_bind.nix
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
