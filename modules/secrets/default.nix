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
      age.identityPaths = if config.environment.persistence != {} then [
        "/persistent/etc/ssh/ssh_host_ed25519_key"
      ] else ["/etc/ssh/ssh_host_ed25519_key"];
      assertions = [{
        assertion = !(cfg.desktop.enable && enabled_server_secrets);
        message = "Enable either desktop or server's secrets, not both!";
      }];
    }
    (mkIf cfg.desktop.enable {
      age.secrets = {
        "test.key" = {
          file = "${mysecrets}/test.key.age";
          path = "/etc/test.key";
        } // noaccess;
      };
    })
  ]);
}
