{pkgs, lib, config, myvars, ...}: let
  server_pub_crt = "${myvars.secrets_dir}/proteus_server.pub.pem";
  server_priv_crt_base = {file = "${myvars.secrets_dir}/proteus_server.priv.pem.age"; mode = "0400";};
  # server_priv_crt_proteus = config.age.secrets."proteus_server.priv.pem".path;
in {
  age.secrets."proteus_server.priv.pem" = server_priv_crt_base // {owner = myvars.username;};
  networking.firewall = {
    allowedTCPPorts = [
      53 # unbound TCP
      443 # WebDAV
      636 # OpenLDAP (secure)
      853 # unbound DoT
      5201 # iperf3
      8888 # Atuin Server
      22000 # Syncthing TCP transfers
      53317 # LocalSend (HTTP/TCP)
    ];
    allowedUDPPorts = [
      53 # unbound
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
        enable_https = true;
        # certificate_file = server_pub_crt;
        # certificate_key_file = server_priv_crt_proteus;
      }];
      webdavd.bindings = [{
        # address = "0.0.0.0";
        port = 8443;
        enable_https = false;
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
    ensureDatabases = ["mydatabase" "atuin"]; # TODO: Learn
    ensureUsers = [
      {name = "proteus"; ensureClauses = {login = true; /*superuser = true;*/ createdb = true;};}
      {name = "atuin"; ensureDBOwnership = true;}
    ];
    authentication = ''
      #type database DBuser auth-method [auth-options]
      local all all trust
      host all all 100.64.0.0/10 ldap ldapurl="ldaps://openldap.proteus.eu.org/ou=People,dc=tailba6c3f,dc=ts,dc=net?uid?sub"
      host all all fd7a:115c:a1e0::/48 ldap ldapurl="ldaps://openldap.proteus.eu.org/ou=People,dc=tailba6c3f,dc=ts,dc=net?uid?sub"
    '';
  };
  ## END services_postgresql.nix
  ## START services_atuin.nix
  age.secrets."atuin.env" = {file = "${myvars.secrets_dir}/atuin.env.age"; mode = "0400"; owner = "root";};
  systemd.services.atuin.serviceConfig.EnvironmentFile = config.age.secrets."atuin.env".path;
  services.atuin = {
    enable = true;
    openFirewall = true;
    # host = "0.0.0.0";
    database.uri = null;
    openRegistration = true;
  };
  ## END services_atuin.nix
  ## START services_immich.nix
  age.secrets."immich.env" = {file = "${myvars.secrets_dir}/immich.env.age"; mode = "0400"; owner = "root";};
  services.immich = {
    enable = true;
    openFirewall = true;
    host = "127.0.0.1";
    database.host = "proteus-nuc.tailba6c3f.ts.net";
    secretsFile = config.age.secrets."immich.env".path;
  };
  ## END services_immich.nix
  ## START services_unbound.nix
  age.secrets."unbound_server.priv.pem" = server_priv_crt_base // {owner = config.services.unbound.user;};
  services.resolved.settings.Resolve.Domains = "~proteus.eu.org";
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
        {name = "proteus.eu.org."; zonefile = "${myvars.secrets_dir}/proteus.eu.org.zone";}
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
      entryPoints = {
        # Force HTTP to HTTPS redirect globally
        web = {address = ":80"; http.redirections.entryPoint = {to = "websecure"; scheme = "https";};};
        websecure = {address = ":443";};
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
      http = let domain = "proteus.eu.org"; in {
        routers = {
          atuin = {
            rule = "Host(`atuin.${domain}`)";
            entryPoints = ["websecure"];
            service = "atuin";
            tls = {}; # Enables TLS using the default cert provided above
          };
          immich = {
            rule = "Host(`immich.${domain}`)";
            entryPoints = ["websecure"];
            service = "immich";
            tls = {}; # Enables TLS using the default cert provided above
          };
          sftpgo-webui = {
            rule = "Host(`sftpgo.${domain}`)";
            entryPoints = ["websecure"];
            service = "sftpgo-webui";
            tls = {};
          };
          sftpgo-webdav = {
            rule = "Host(`webdav.${domain}`)";
            entryPoints = ["websecure"];
            service = "sftpgo-webdav";
            tls = {};
          };
        };
        services = {
          atuin.loadBalancer.servers = [{url = "http://127.0.0.1:${builtins.toString config.services.atuin.port}";}];
          immich.loadBalancer.servers = [{url = "http://127.0.0.1:${builtins.toString config.services.immich.port}";}];
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
          openldap-secure = {
            # Catch-all for traffic on this port. standard LDAP clients (like
            # ldapsearch and many older legacy systems) do not send SNI data.
            rule = "HostSNI(`*`)";
            entryPoints = ["ldaps"];
            service = "openldap-backend";
            tls = {};
          };
        };
        services = {
          openldap-backend.loadBalancer.servers = [
            # Point to the standard UNENCRYPTED local LDAP port.
            {address = "127.0.0.1:389";}
          ];
        };
      };
    };
  };
  ## END services_traefik.nix
  ## TODO: paperless to host receipts & statements for Beancount
}
