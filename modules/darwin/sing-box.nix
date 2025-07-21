{config, lib, pkgs, ...}: let
  cfg = config.services.sing-box;
  sing-box_dir = "/Library/Application Support/sing-box";
in {
  options.services.sing-box = {
    enable = lib.mkEnableOption "sing-box universal proxy platform";
    package = lib.mkPackageOption pkgs "sing-box" {};
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [cfg.package];
    launchd.daemons.sing-box.serviceConfig = {
      KeepAlive = {
        Crashed = lib.mkDefault true;
        SuccessfulExit = lib.mkDefault false;
      };
      Label = lib.mkOverride 999 "io.nekohasekai.sing-box";
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ("/bin/wait4path /nix/store"
          + " && install -dm700 \"${sing-box_dir}\""
          + " && exec ${lib.getExe cfg.package} -c ${config.age.secrets."config.json".path} -D \"${sing-box_dir}\" run"
        )
      ];
      RunAtLoad = lib.mkDefault true;
      StandardErrorPath = lib.mkDefault "/Library/Logs/org.nixos.sing-box.stderr.log";
      StandardOutPath = lib.mkDefault "/Library/Logs/org.nixos.sing-box.stdout.log";
    };
  };
}
