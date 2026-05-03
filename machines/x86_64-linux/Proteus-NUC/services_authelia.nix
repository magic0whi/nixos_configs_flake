{myvars, config, ...}: {
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
      # To generate those secrets, run
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
    # https://github.com/authelia/authelia/blob/8a7b642dd78f29c76d126b6f53806472b2a360bd/config.template.yml
    settings = {
      theme = "dark";
      default_2fa_method = "totp";
      # Use the new server.address syntax required by the module
      server.address = "tcp://127.0.0.1:9092";
      # This allows the login cookie to work across all your subdomains
      session.cookies = [{
        inherit (myvars) domain;
        authelia_url = "https://auth.${myvars.domain}";
        same_site = "lax";
        inactivity = "5 minutes";
        expiration = "1 hour";
        remember_me = "1 month";
      }];
      storage.postgres = {
        address = "tcp://postgresql.${myvars.domain}:${builtins.toString config.services.postgresql.settings.port}";
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
          address = "ldaps://openldap.${myvars.domain}:636";
          # Password is injected via environment variable
          # password = "password";
          timeout = "5s";
          base_dn = "dc=tailba6c3f,dc=ts,dc=net";
          additional_users_dn = "ou=People";
          users_filter = "(&({username_attribute}={input})(objectClass=person))";
          additional_groups_dn = "ou=Group";
          groups_filter = "(member={dn})";
          user = "cn=Manager,dc=tailba6c3f,dc=ts,dc=net";
          attributes = {
            username = "uid";
            display_name = "cn";
            mail = "mail";
            group_name = "cn";
            nickname = "givenName";
          };
        };
      };
      access_control = {
        rules = [ # Orders does matter
          {domain = "syncthing.${myvars.domain}"; policy = "bypass"; resources = ["^/rest/noauth/.*$"];}
          {domain = "*.${myvars.domain}"; policy = "one_factor";}
        ];
        default_policy = "deny";
      };
      identity_providers = {
        oidc = {
          cors = {endpoints = ["authorization" "token" "revocation" "introspection" "userinfo"];};
          # https://www.authelia.com/configuration/identity-providers/openid-connect/clients/
          clients = [
            {
              client_id = "papra";
              client_name = "Papra";
              # nix run nixpkgs#authelia -- crypto rand --length 64 --charset alphanumeric
              # nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512 --password <YOUR_RAW_SECRET>
              client_secret = "$pbkdf2-sha512$310000$3KSvvBJnoLyJDoKDBIBcZQ$dMQmccJ6Y4hrj.tv.dD3KFzLcsPCsMNRZFTpHUiInVcSX0eBR5T6jemXfcUaob9PsbgHBwRNCjtXiBNl6lOc7g";
              redirect_uris = ["https://papra.${myvars.domain}/api/auth/oauth2/callback/authelia"];
              # authorization_policy = "one_factor";
              token_endpoint_auth_method = "client_secret_post";
            }
            {
              client_id = "forgejo";
              client_name = "Forgejo";
              client_secret = "$pbkdf2-sha512$310000$hHi.uSu97kUzfh.X9ijhXA$.IL0RMznXtdwXGTYq9eKV.83nIXI0glK7v.IaFYu5xVpweng.zo5L5PpuC6aQgY6R9ROgSFQrHbve3LK50j/yg";
              redirect_uris = ["https://git.${myvars.domain}/user/oauth2/Authelia/callback"];
              pkce_challenge_method = "S256"; # effectively enables the require_pkce
            }
            { # https://www.reddit.com/r/selfhosted/comments/1llq665/minio_oidc_login_removed_in_latest_release/
              # TODO: Migrate to Garage
              client_id = "minio";
              client_name = "MinIO";
              client_secret = "$pbkdf2-sha512$310000$QdCiXrZt/Z67VAHrkiX5.Q$L3yWQD5Zp9l7WWdLx5dNB6Rqigz8BjH0iTD4NPp48K89wundrn9JaeQT6UG/IwhsEm30uKE39q9VrOi4mU64TA";
              redirect_uris = ["https://minio.${myvars.domain}/oauth_callback"];
            }
            {
              client_id = "plane";
              client_name = "Plane";
              client_secret = "$pbkdf2-sha512$310000$js.q7nxEc0JzjQN3NRyyrA$0F2fFhnC3HJspJUhFSp56F4Rl0PhzaYV.J9TytIfxZfiE7GDAuHIYKxSa262k/rf7d/vgOVHVa5a9C9P1YIYRg";
              redirect_uris = ["https://plane.${myvars.domain}/auth/gitea/callback" "https://plane.${myvars.domain}/auth/gitea/callback/"];
              scopes = ["openid" "email" "profile"];
              token_endpoint_auth_method = "client_secret_post";
            }
          ];
        };
      };
    };
  };
}
