{config, myvars, pkgs, lib, ...}: let
  restartUnits = [
    "nextcloud-setup.service" "nextcloud-cron" "nextcloud-update-plugins.service" "nextcloud-update-db.service"
    "phpfpm-nextcloud"
  ];
in {
  sops.secrets = let sopsFile = "${myvars.secrets_dir}/Proteus-Desktop.sops.yaml"; in {
    nextcloud_db_password = {inherit sopsFile restartUnits;};
    nextcloud_admin_password = {inherit sopsFile restartUnits;};
    nextcloud_oidc_client_secret = {inherit sopsFile restartUnits;};
  };
  # Add RequiresMountsFor to wait for storage mounted
  systemd.services = let clean_units = map (s: lib.strings.removeSuffix ".service" s) restartUnits;
  in lib.mkMerge [(lib.attrsets.genAttrs clean_units (name: {unitConfig.RequiresMountsFor = [myvars.storage_path];}))];

  services.nextcloud = {
    enable = true;
    # package = pkgs.nextcloud33;
    hostName = "nextcloud.${myvars.domain}";
    # https = true;

    # home = "/srv/nextcloud";
    datadir = "${myvars.storage_path}/nextcloud";

    config = {
      dbtype = "pgsql";
      dbhost = "postgresql.${myvars.domain}";
      dbpassFile = config.sops.secrets.nextcloud_db_password.path;

      adminpassFile = config.sops.secrets.nextcloud_admin_password.path;
    };
    maxUploadSize = "20G";

    secrets.oidc_login_client_secret = config.sops.secrets.nextcloud_oidc_client_secret.path;
    settings = {
      trusted_proxies = ["127.0.0.1" "::1"];
      overwriteprotocol = "https";

      allow_user_to_change_display_name = false;
      lost_password_link = "disabled";

      oidc_login_provider_url = "https://auth.${myvars.domain}"; # all other URLs are auto-discovered from .well-known
      oidc_login_client_id = "nextcloud";
      oidc_login_auto_redirect = true;
      oidc_login_logout_url = "https://auth.${myvars.domain}/logout"; # Redirect to this page after logging out the user
      oidc_login_end_session_redirect = false; # User will be redirected to the `oidc_login_logout_url` after logout
      oidc_login_button_text = "Log in with Authelia";
      oidc_login_hide_password_form = true;
      oidc_login_use_id_token = false; # Use ID Token instead of UserInfo

      oidc_login_attributes = {
        id = "preferred_username";
        name = "name";
        mail = "email";
        groups = "groups";
        is_admin = "is_nextcloud_admin";
      };

      oidc_login_default_group = "oidc"; # Default group to add users to
      # Use external storage instead of a symlink to the home directory. Requires the files_external app to be enabled
      oidc_login_scope = "openid profile email groups nextcloud_userinfo";
      oidc_login_disable_registration = false;
      oidc_login_redir_fallback = false; # Fallback to direct login if login from OIDC fails
      oidc_create_groups = true;
      oidc_login_webdav_enabled = false;
      # Enable authentication with user/password for DAV clients that do not support token authentication
      oidc_login_password_authentication = false;
      oidc_login_update_avatar = false;
      oidc_login_code_challenge_method = "S256"; # Enable PKCE flow for enhanced security
    };

    extraApps = {inherit (pkgs.nextcloud33Packages.apps) oidc_login;};
  };
  # Let Traefik own :80/:443, and move the generated Nextcloud nginx vhost to loopback.
  services.nginx.virtualHosts."${config.services.nextcloud.hostName}".listen = [{addr = "127.0.0.1"; port = 8080;}];
}
