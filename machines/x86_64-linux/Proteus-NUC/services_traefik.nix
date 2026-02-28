{config, myvars, lib, ...}: let
  server_pub_crt = "${myvars.secrets_dir}/proteus_server.pub.pem";
  domain = "proteus.eu.org";
  tailnet = "tailba6c3f.ts.net";
in {
  networking.firewall = {
    allowedTCPPorts = [
      443 # Traefik
      636 # OpenLDAP (secure)
      853 # BIND DoT
      # config.home-manager.users.proteus.services.mpd.network.port
    ];
    allowedUDPPorts = [
      443 # Traefik (QUIC)
      # 636 # OpenLDAP (secure, generally not used)
      # 853 # unbound DNS-over-QUIC, bind don't support it
    ];
  };
  age.secrets."traefik_server.priv.pem" = {
    file = "${myvars.secrets_dir}/proteus_server.priv.pem.age";
    mode = "0400";
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
        # Add the standard DoT port as a TCP entrypoint
        dot = {address = ":853";};
        # mpd = {address = ":6601";};
      };
    };
    # Dynamic configuration defines routing rules, backend services, and certificate management.
    dynamicConfigOptions = {
      # Establish the default fallback certificate.
      # This is critical for TCP clients (like `ldapsearch`) that do not send
      # Server Name Indication (SNI) data during the TLS handshake. Without this,
      # Traefik serves an untrusted dummy certificate.
      tls.stores.default.defaultCertificate = {
        certFile = server_pub_crt; keyFile = config.age.secrets."traefik_server.priv.pem".path;
      };
      # For other domains
      # tls.certificates = [{certFile = server_pub_crt; keyFile = config.age.secrets."traefik_server.priv.pem".path;}];
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
          aria2-rpc = {
            rule = "Host(`aria2.${domain}`)"; entryPoints = ["websecure"]; service = "aria2-rpc"; tls = {};
          };
          qinglong = {
            rule = "Host(`ql.${domain}`)"; entryPoints = ["websecure"]; service = "qinglong"; tls = {};
          };
          doh = {
            # Intercept standard DoH queries at the apex domain
            rule = "(Host(`${domain}`) || Host(`ns1.${domain}`) || Host(`proteus-nuc.${tailnet}`)) && Path(`/dns-query`)";
            entryPoints = ["websecure"];
            tls = {}; # Traefik decrypts the HTTPS traffic
            service = "doh";
          };
          sb = {
            # Matches the root, but EXCLUDES the API paths
            rule = "Host(`sb.${domain}`)";
            entryPoints = ["websecure"];
            # Force yourself to log in via OpenLDAP to see the dashboard
            middlewares = ["authelia-auth"];
            service = "sb-dashboard";
            tls = {};
          };
        };
        services = {
          authelia-backend.loadBalancer.servers = [{url = "http://127.0.0.1:9092";}];
          atuin.loadBalancer.servers = [
            {url = "http://127.0.0.1:${builtins.toString config.services.atuin.port}";}
          ];
          immich.loadBalancer.servers = [
            {url = "http://127.0.0.1:${builtins.toString config.services.immich.port}";}
          ];
          paperless.loadBalancer.servers = [
            {url = "http://127.0.0.1:${builtins.toString config.services.paperless.port}";}
          ];
          sftpgo-webui.loadBalancer.servers = [
            {url = "http://127.0.0.1:${builtins.toString (builtins.head config.services.sftpgo.settings.httpd.bindings).port}";}
            {url = "http://[::1]:${builtins.toString (builtins.head config.services.sftpgo.settings.httpd.bindings).port}";}
          ];
          sftpgo-webdav.loadBalancer.servers = [
            {url = "http://127.0.0.1:${builtins.toString (builtins.head config.services.sftpgo.settings.webdavd.bindings).port}";}
            {url = "http://[::1]:${builtins.toString (lib.last config.services.sftpgo.settings.webdavd.bindings).port}";}
          ];
          # Even though it's WebSockets, we define it as http://
          aria2-rpc.loadBalancer.servers = [{url = "http://127.0.0.1:6800";}];
          qinglong.loadBalancer.servers = [{url = "http://127.0.0.1:5700";}];
          # use HTTP/2 Cleartext (h2c) when talking to BIND's local port.
          doh.loadBalancer.servers = [
            {url = "h2c://127.0.0.1:8053";}
            {url = "h2c://[::1]:8053";}
          ];
          sb-dashboard.loadBalancer.servers = [{url = "http://127.0.0.1:9091";}];
        };
      };
      tcp = {
        routers = {
          # Catch-all for traffic on this port. standard LDAP clients (like
          # ldapsearch and many older legacy systems) do not send SNI data.
          openldap-secure = {
            rule = "HostSNI(`*`)";
            entryPoints = ["ldaps"];
            service = "openldap-backend";
            tls = {};
          };
          dot = {
            rule = "HostSNI(`${domain}`) || HostSNI(`ns1.${domain}`) || HostSNI(`proteus-nuc.${tailnet}`)";
            entryPoints = ["dot"];
            service = "dot";
            tls = {};
          };
          # mpd = {
          #   rule = "HostSNI(`*`)";
          #   encryPoints = ["mpd"];
          #   service = "mpd";
          #   tls = {};
          # };
        };
        services = {
          openldap-backend.loadBalancer = {
            # Instruct Traefik to inject the PROXY protocol v2 header
            proxyProtocol.version = 2;
            servers = [{address = "127.0.0.1:389";}{address = "[::1]:389";}];
          };
          # Forward raw DNS to BIND's local 53
          dot.loadBalancer = {
            proxyProtocol.version = 2;
            servers = [{address = "127.0.0.1:8530";}{address = "[::1]:8530";}];
          };
          # mpd.loadBalancer = [{address="127.0.0.1:${builtins.toString config.home-manager.users.${myvars.username}.services.mpd.network.port}";}];
        };
      };
    };
  };
}
