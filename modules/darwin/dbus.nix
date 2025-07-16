{config, lib, ...}: let
  cfg = config.services.dbus;
in with lib; {
  options.services.dbus = {
    enable = mkEnableOption "Simple interprocess messaging system";
  };
  config = mkIf cfg.enable {
    homebrew.brews = ["dbus"];
    launchd.daemons.dbus = {
      command = mkDefault "/opt/homebrew/bin/dbus-daemon --nofork --session";
      serviceConfig = {
        Label = mkOverride 999 "org.freedesktop.dbus-session";
        ServiceIPC = mkDefault true;
        Sockets.unix_domain_listener.SecureSocketWithKey = mkDefault "DBUS_LAUNCHD_SESSION_BUS_SOCKET";
      };
    };
  };
}
