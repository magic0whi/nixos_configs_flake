{config, myvars, lib, ...}: let
  server_pub_crt = "${myvars.secrets_dir}/proteus_server.pub.pem";
in {
  networking.firewall = { allowedTCPPorts = [80 443]; allowedUDPPorts = [443];};
  age.secrets."traefik_server.priv.pem" = {
    file = "${myvars.secrets_dir}/proteus_server.priv.pem.age";
    mode = "0400"; owner = config.systemd.services.traefik.serviceConfig.User;
  };
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      global = {checkNewVersion = false; sendAnonymousUsage = false;};
      api.dashboard = true;
      entryPoints = {
        web = {address = ":80"; http.redirections.entryPoint = {to = "websecure"; scheme = "https";};};
        websecure = {
          address = ":443";
          http3 = {};
          transport.respondingTimeouts = {readTimeout = "600s"; idleTimeout = "600s";};
        };
      };
    };
    dynamicConfigOptions = {
      tls.stores.default.defaultCertificate = {
        certFile = server_pub_crt; keyFile = config.age.secrets."traefik_server.priv.pem".path;
      };
      http = {
        middlewares.authelia-auth.forwardAuth = {
          address = "https://auth.${myvars.domain}/api/authz/forward-auth?authelia_url=https://auth.${myvars.domain}/";
          trustForwardHeader = true;
          authResponseHeaders = ["Remote-User" "Remote-Groups" "Remote-Email" "Remote-Name"];
        };
        routers = {
          traefik-dashboard = {
            rule = "Host(`traefik-desktop.${myvars.domain}`)";
            entryPoints = ["websecure"];
            # Protect the dashboard
            middlewares = ["authelia-auth"];
            service = "api@internal";
            tls = {};
          };
          sb = {
            rule = "Host(`sb-desktop.${myvars.domain}`)";
            entryPoints = ["websecure"];
            middlewares = ["authelia-auth"];
            service = "sb-dashboard";
            tls = {};
          };
          syncthing = {
            rule = "Host(`syncthing-desktop.${myvars.domain}`)";
            entryPoints = ["websecure"];
            middlewares = ["authelia-auth"];
            service = "syncthing-dashboard";
            tls = {};
          };
          webdav = {
            rule = "Host(`webdav.${myvars.domain}`)"; entryPoints = ["websecure"]; service = "webdav"; tls = {};
          };
        };
        services = {
          sb-dashboard.loadBalancer.servers = [{url = "http://127.0.0.1:9091";}];
          syncthing-dashboard.loadBalancer = {
            passHostHeader = false;
            servers = let
              syncthing_port = lib.last (lib.strings.splitString
                ":"
                config.home-manager.users.${myvars.username}.services.syncthing.guiAddress);
            in [{url = "http://127.0.0.1:${syncthing_port}";}];
          };
          webdav.loadBalancer = {
            servers = [{url = "http://127.0.0.1:${builtins.toString config.services.webdav.settings.port}";}];
            healthCheck = {path = "/__dufs__/health"; interval = "15s"; timeout = "3s";};
          };
        };
      };
    };
  };
}
