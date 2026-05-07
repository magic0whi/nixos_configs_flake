{myvars, pkgs, config, lib}: {
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
}
