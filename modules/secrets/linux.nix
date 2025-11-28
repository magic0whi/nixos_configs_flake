{config, agenix, lib, pkgs, mylib, myvars, ...}: let
  cfg = config.modules.secrets;
  enabled_server_secrets =
    cfg.server.application.enable
    || cfg.server.network.enable
    || cfg.server.operation.enable
    || cfg.server.kubernetes.enable
    || cfg.server.webserver.enable
    || cfg.server.storage.enable;
  noaccess = {mode = "0000"; owner = "root";};
  high_security = {mode = "0500"; owner = "root";};
  user_readable = {mode = "0500"; owner = myvars.username;};
  custom_files_dir = mylib.relative_to_root "custom_files";
in {
  options.modules.secrets = {
    enabled = lib.mkOption {
      readOnly = true;
      type = lib.types.bool;
      default = cfg.desktop.enable || enabled_server_secrets;
      defaultText = lib.literalMD "`true` if secret is enabled";
      description = "True if either modules.secrets.desktop or modules.secrets.server.* is enabled";
    };
    desktop.enable = lib.mkEnableOption "NixOS Secrets for Desktops";

    server.application.enable = lib.mkEnableOption "NixOS Secrets for Application Servers";
    server.network.enable = lib.mkEnableOption "NixOS Secrets for Network Servers";
    server.operation.enable = lib.mkEnableOption "NixOS Secrets for Operation Servers(Backup, Monitoring, etc)";
    server.kubernetes.enable = lib.mkEnableOption "NixOS Secrets for Kubernetes";
    server.webserver.enable = lib.mkEnableOption "NixOS Secrets for Web Servers(contains tls cert keys)";
    server.storage.enable = lib.mkEnableOption "NixOS Secrets for HDD Data's LUKS Encryption";
  };
  config = lib.mkIf (config.modules.secrets.enabled) (lib.mkMerge [
    {
      environment.systemPackages = [agenix.packages."${pkgs.stdenv.hostPlatform.system}".default];
      age.identityPaths = if config.environment.persistence != {} then [
        "/persistent${config.users.users.${myvars.username}.home}/sync_work/3keys/pgp2ssh.priv.key"
      ] else [
        "${config.users.users.${myvars.username}.home}/sync_work/3keys/pgp2ssh.priv.key"
      ];
      assertions = [{
        assertion = !(cfg.desktop.enable && enabled_server_secrets);
        message = "Enable either desktop or server's secrets, not both!";
      }];
    }
    (lib.mkIf cfg.desktop.enable {
      age.secrets = {
        "config.json" = {file = "${custom_files_dir}/config.json.age";} // noaccess;
        "proteus_smb.priv" = {file = "${custom_files_dir}/proteus_smb.priv.age";} // high_security;
        "proteus_server.priv.pem" = {file = "${custom_files_dir}/proteus_server.priv.pem.age";} // user_readable;
      };
    })
  ]);
}
