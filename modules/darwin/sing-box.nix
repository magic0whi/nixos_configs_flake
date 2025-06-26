{config, lib, pkgs, ...}: let
  cfg = config.services.sing-box;
  sing-box_dir = "/Library/Application Support/sing-box";
in with lib; {
  options.services.sing-box = {
    enable = mkEnableOption "sing-box universal proxy platform";
    package = mkPackageOption pkgs "sing-box" {};
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [cfg.package];
    launchd.daemons.sing-box.serviceConfig = {
      KeepAlive = {
        Crashed = mkDefault true;
        SuccessfulExit = mkDefault false;
      };
      Label = mkOverride 999 "io.nekohasekai.sing-box";
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ("/bin/wait4path /nix/store"
          + " && install -dm700 \"${sing-box_dir}\""
          + " && exec ${lib.getExe cfg.package} -c ${config.age.secrets."config.json".path} -D \"${sing-box_dir}\" run"
        )
      ];
      RunAtLoad = mkDefault true;
      StandardErrorPath = mkDefault "/Library/Logs/org.nixos.sing-box.stderr.log";
      StandardOutPath = mkDefault "/Library/Logs/org.nixos.sing-box.stdout.log";
    };
  };
}
