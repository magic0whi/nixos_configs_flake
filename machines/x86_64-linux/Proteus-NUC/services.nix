{pkgs, lib, config, myvars, ...}: {
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
  ## BEGIN services_tor.nix
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
  ## END services_tor.nix
  ## BEGIN services_sftpgo.nix
  # services.sftpgo = {
  #   enable = true;
  #   user = myvars.username;
  #   group = myvars.username;
  #   extraReadWriteDirs = [/srv/aria2 config.home-manager.users.${myvars.username}.xdg.userDirs.documents];
  #   settings = {
  #     httpd = {
  #       bindings = [
  #         # Allow reverse proxy
  #         {port = 8081; client_ip_proxy_header = "X-Forwarded-For"; proxy_allowed = ["127.0.0.1"];}
  #         {address = "[::1]"; port = 8081; client_ip_proxy_header = "X-Forwarded-For"; proxy_allowed = ["::1"];}
  #       ];
  #     };
  #     webdavd.bindings = [
  #       {port = 8443; client_ip_proxy_header = "X-Forwarded-For"; proxy_allowed = ["127.0.0.1"];}
  #       {address = "[::1]"; port = 8443; client_ip_proxy_header = "X-Forwarded-For"; proxy_allowed = ["::1"];}
  #     ];
  #   };
  # };
  ## END services_sftpgo.nix
  ## BEGIN services_immich.nix
  sops = let
    sopsFile = "${myvars.secrets_dir}/Proteus-NUC.sops.yaml";
    restartUnits = ["immich-machine-learning.service" "immich-server.service"];
  in {
    secrets = {
      immich_db_password = {inherit sopsFile restartUnits;};
      immich_oauth_secret = {inherit sopsFile restartUnits; owner = config.services.immich.user;};
    };
    templates."immich.env" = {
      inherit restartUnits; content = "DB_PASSWORD=${config.sops.placeholder.immich_db_password}";
    };
  };
  services.immich = {
    enable = true;
    host = "127.0.0.1";
    database.host = "postgresql.${myvars.domain}";
    secretsFile = config.sops.templates."immich.env".path;
    mediaLocation = "/srv/immich";
    settings = { # https://immich.proteus.eu.org/admin/system-settings?isOpen=authentication -> Export as JSON
      server.externalDomain = "https://immich.${myvars.domain}";
      oauth = {
        enabled = true;
        issuerUrl = "https://auth.${myvars.domain}";
        clientId = "immich";
        # NixOS will dynamically inject the contents of this file at runtime through `utils.genJqSecretsReplacement`
        clientSecret._secret = config.sops.secrets."immich_oauth_secret".path;
        autoLaunch = true;
      };
    };
  };
  ## END services_immich.nix
  ## BEGIN services_home_assistant.nix
  services.home-assistant = {
    enable = true;
    # NixOS will automatically fetch the required Python dependencies (like
    # python-miio) and assign Bluetooth capabilities for BLE sensors.
    extraComponents = [
      "default_config"
      "met" # Meteorologisk institute (Met.no)
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
        cors_allowed_origins = ["https://hass.${myvars.domain}"];
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
  ## BEGIN services_sunshine.nix
  # Wake monitor when connect
  # Ref: https://github.com/orgs/LizardByte/discussions/439#discussioncomment-15813284
  security.wrappers = lib.mkIf config.services.sunshine.enable {conntrack = {
    source = "${pkgs.conntrack-tools}/bin/conntrack";
    # conntrack needs `cap_net_admin` to run as a normal user
    capabilities = "cap_net_admin+ep";
    owner = "root"; group = "root";
  };};
  # Adapt for Hyprland
  systemd.user.services = lib.mkIf (
    config.services.sunshine.enable
    && config.home-manager.users.${myvars.username}.wayland.windowManager.hyprland.enable) {
    sunshine-wake-monitor = {
      description = "Monitor Sunshine TCP connections and wake monitors";
      after = ["hyprland-session.target"];
      wantedBy = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = pkgs.writeShellScript "sunshine_wake_monitor" ''
          ${config.security.wrapperDir}/conntrack -E -e new -p tcp --dport ${builtins.toString (config.services.sunshine.settings.port - 5)} | \
          while read line; do
            echo "New Sunshine connection detected, waking up the monitors"
            ${lib.getExe' pkgs.hyprland "hyprctl"} --instance 0 'dispatch dpms on'
            sleep 5
          done
        '';
        Restart = "on-failure";
  };};};
  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    settings = {
      adapter_name = if config.home-manager.users.${myvars.username}.wayland.windowManager.hyprland.nvidia then
        "/dev/dri/${myvars.dgpu_sym_name}"
      else
        "/dev/dri/${myvars.igpu_sym_name}";
      origin_web_ui_allowed = "pc";
    };
  };
  ## END services_sunshine.nix
  ## BEGIN services_caddy.nix
  # TODO: Change to given user caddy `openssh.authorizedKeys.keys` and change the Action for notebook deploy
  # Ensure the web root exists with the correct permissions.
  # Caddy runs as user 'caddy', group 'caddy' by default according to the
  # module. CI script will run as 'proteus', so we make the folder owned by
  # `myvars.username` but give the group (which default to 'caddy') read access.
  systemd.tmpfiles.settings."10-caddy-create-webroot" = let
    root_path = builtins.head (builtins.match
      ''.*root \* ([a-zA-Z0-9/_-]+).*''
      # Get the first attrset under services.caddy.virtualHosts
      (builtins.head (builtins.attrValues config.services.caddy.virtualHosts)).extraConfig
    );
  in {${root_path}.d = {mode = "2755"; user = myvars.username; group = config.services.caddy.group;};};
  services.caddy = {
    enable = true;
    # Caddy doesn't need to bind to public ports (80/443) since Traefik handles
    # that. We can tell Caddy's global config not to attempt ACME/HTTPS bindings.
    globalConfig = ''auto_https off'';
    virtualHosts."http://notebook.${myvars.domain}:8080" = {
      listenAddresses = ["127.0.0.1" "[::1]"];
      extraConfig = ''
        # respond "Hello, world!" # For debug
        root * /srv/www
        file_server
      '';
    };
  };
  ## END services_caddy.nix
  ## BEGIN services_forgejo.nix
  # Decrypt the runner token using your existing age setup
  # Create a file secrets/forgejo_runner_token.env.age containing:
  # TOKEN=your_generated_token,
  # see below:
  # `services.authelia.instances.main.settings.identity_providers.oidc.clients`
  age.secrets."forgejo_authelia_secret" = {
    file = "${myvars.secrets_dir}/forgejo_authelia_secret.age"; mode = "0400"; owner = "forgejo";
  };
  services.forgejo = {
    enable = true;
    database.type = "postgres"; # Module will automatically provision PostgreSQL
    lfs.enable = true;
    settings = {
      server = {
        DOMAIN = "git.${myvars.domain}";
        ROOT_URL = "https://git.${myvars.domain}/";
        HTTP_ADDR = "127.0.0.1";
        # PROTOCOL = "http+unix"; # http through unix
      };
        # Only allow auth methods added through CLI
      openid.ENABLE_OPENID_SIGNIN = false;
      oauth2_client = {
        ENABLE_AUTO_REGISTRATION = true;
        ACCOUNT_LINKING = "auto";
        USERNAME = "userid";
      };
      # Delegating registration entirely to Authelia
      service.ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
      # Add support for actions, based on act: https://github.com/nektos/act
      actions = {ENABLED = true; DEFAULT_ACTIONS_URL = "github";};
    };
  };
  systemd.services.forgejo.preStart = ''
    mkdir -p ${config.services.forgejo.stateDir}/custom/public/assets/img/auth/
    cp -f ${pkgs.authelia.src}/docs/static/images/branding/logo.png ${config.services.forgejo.stateDir}/custom/public/assets/img/auth/authelia.png
  '';

  systemd.services.forgejo.postStart = let
    forgejo_exe = lib.getExe config.services.forgejo.package;
  in ''
    # Wait for Forgejo to be fully ready to accept CLI commands
    while [ "$(${lib.getExe pkgs.curl} -sSf https://git.${myvars.domain}/api/healthz | ${lib.getExe pkgs.jq} -r '.status')" != "pass" ]; do
      sleep 1
    done

    # Read the secret from your age file
    OIDC_SECRET=$(cat ${config.age.secrets."forgejo_authelia_secret".path})

    # The environment variables (FORGEJO_WORK_DIR, etc.) are already injected by systemd.
    FORGEJO_CLI="${forgejo_exe} --config ${config.services.forgejo.stateDir}/custom/conf/app.ini admin auth"

    # Check if the Authelia auth source already exists
    if ! $FORGEJO_CLI list | grep -q "Authelia"; then
      echo "Adding Authelia OIDC provider..."
      $FORGEJO_CLI add-oauth \
        --name Authelia \
        --provider openidConnect \
        --key "forgejo" \
        --secret "$OIDC_SECRET" \
        --auto-discover-url "https://auth.${myvars.domain}/.well-known/openid-configuration" \
        --icon-url "/assets/img/auth/authelia.png"
    else
      echo "Updating existing Authelia OIDC provider..."
      AUTHELIA_ID=$($FORGEJO_CLI list | ${lib.getExe pkgs.gawk} '/Authelia/ {print $1;}')
      $FORGEJO_CLI update-oauth \
        --name Authelia \
        --id $AUTHELIA_ID \
        --provider openidConnect \
        --key "forgejo" \
        --secret "$OIDC_SECRET" \
        --auto-discover-url "https://auth.${myvars.domain}/.well-known/openid-configuration" \
        --icon-url "/assets/img/auth/authelia.png"
    fi
  '';
  # Generate the Runner Token:
  # `sudo -u forgejo ${pkgs.forgejo} forgejo-cli --config ${config.services.forgejo.stateDir}/custom/conf/app.ini forgejo-cli actions generate-runner-token`
  age.secrets."forgejo_runner_token.env" = {
    file = "${myvars.secrets_dir}/forgejo_runner_token.env.age";
    mode = "0400";
    owner = config.systemd.services."gitea-runner-${builtins.head (builtins.attrNames config.services.gitea-actions-runner.instances)}".serviceConfig.User;
  };
  # Local Action Runner connecting to your Forgejo instance
  # Docker is required to execute Docker-based action labels
  virtualisation.docker.enable = true;
  services.gitea-actions-runner = let
    default_instance = {
      enable = true;
      name = "${config.networking.hostName}-runner";
      url = "https://git.${myvars.domain}";
      tokenFile = config.age.secrets."forgejo_runner_token.env".path;
      labels = [
        "debian-latest:docker://node:20-bookworm"
        # fake the ubuntu name, because node provides no ubuntu builds
        "ubuntu-latest:docker://node:20-bookworm"
        # "ubuntu-24.04-arm:docker://node:20-bookworm"
      ];
      # https://gitea.com/gitea/act_runner/src/commit/40dcee0991c3bd33b657bb77aa1f2f46d69cc0e2/internal/pkg/config/config.example.yaml
      settings = {
        # The nodejs still couldn't recognize my self-signed cert
        runner.capacity = 3; # Set to your desired number of simultaneous jobs
        runner.envs.NODE_EXTRA_CA_CERTS = config.security.pki.caBundle;
        container = {
          options = "-v ${config.security.pki.caBundle}:/etc/ssl/certs/ca-certificates.crt:ro";
          valid_volumes = [config.security.pki.caBundle];
          force_pull = false;
        };
      };
    };
  in {
    package = pkgs.forgejo-runner;
    instances = {
      x86_64 = default_instance;
      # arm64 = lib.recursiveUpdate default_instance {
      #   name = "${config.networking.hostName}-runner-arm64";
      #   labels = ["ubuntu-24.04-arm:docker://node:20-bookworm"];
      #   settings = {
      #     runner.capacity = 1;
      #     container.options = default_instance.settings.container.options + " --platform=linux/arm64";
      #     force_pull = false;
      #   };
      # };
      # riscv64 = lib.recursiveUpdate default_instance {
      #   name = "${config.networking.hostName}-runner-riscv64";
      #   labels = ["ubuntu-24.04-riscv64:docker://custom-node-riscv64:22.22.0"];
      #   settings = {
      #     runner.capacity = 1;
      #     container.options = default_instance.settings.container.options + " --platform=linux/riscv64";
      #     force_pull = false;
      #   };
      # };
    };
  };
  ## END services_forgejo.nix
}
