{config, agenix, lib, pkgs, mylib, myvars, ...}: with lib; let
  cfg = config.modules.secrets;
  enabled_server_secrets =
    cfg.server.application.enable
    || cfg.server.network.enable
    || cfg.server.operation.enable
    || cfg.server.kubernetes.enable
    || cfg.server.webserver.enable
    || cfg.server.storage.enable;
  noaccess = {
    mode = "0000";
    owner = "root";
  };
  high_security = {
    mode = "0500";
    owner = "root";
  };
  user_readable = {
    mode = "0500";
    owner = myvars.username;
  };
  mysecrets = mylib.relative_to_root "custom_files";
in {
  imports = [agenix.nixosModules.default];
  options.modules.secrets = {
    desktop.enable = mkEnableOption "NixOS Secrets for Desktops";

    server.application.enable = mkEnableOption "NixOS Secrets for Application Servers";
    server.network.enable = mkEnableOption "NixOS Secrets for Network Servers";
    server.operation.enable = mkEnableOption "NixOS Secrets for Operation Servers(Backup, Monitoring, etc)";
    server.kubernetes.enable = mkEnableOption "NixOS Secrets for Kubernetes";
    server.webserver.enable = mkEnableOption "NixOS Secrets for Web Servers(contains tls cert keys)";
    server.storage.enable = mkEnableOption "NixOS Secrets for HDD Data's LUKS Encryption";
  };
  config = mkIf (cfg.desktop.enable || enabled_server_secrets) (mkMerge [
    {
      environment.systemPackages = [agenix.packages."${pkgs.system}".default];
      age.identityPaths = if config.environment ? persistence && config.environment.persistence != {} then [
        "/persistent${config.users.users.${myvars.username}.home}/sync_work/3keys/private/legacy/proteus_ed25519.key"
      ] else ["${config.users.users.${myvars.username}.home}/sync_work/3keys/private/legacy/proteus_ed25519.key"];
      assertions = [{
        assertion = !(cfg.desktop.enable && enabled_server_secrets);
        message = "Enable either desktop or server's secrets, not both!";
      }];
    }
    (mkIf cfg.desktop.enable {
      age.secrets = {
        "config.json" = {file = "${mysecrets}/config.json.age";} // noaccess;
        "proteus.smb" = {file = "${mysecrets}/proteus.smb.age";} // high_security;
      };
    })
  ]);
}
