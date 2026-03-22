{myvars, config, ...}: {
  time.timeZone = "Asia/Hong_Kong";
  age.secrets."sb_client_darwin.json" = {
    file = "${myvars.secrets_dir}/sb_client_darwin.json.age";
    mode = "0000";
    owner = "root";
  };
  services.sing-box.enable = true;
  services.sing-box.config_file = config.age.secrets."sb_client_darwin.json".path;
  launchd.daemons.tailscaled.serviceConfig = {
    StandardErrorPath = "/Library/Logs/com.tailscale.ipn.stderr.log";
    StandardOutPath = "/Library/Logs/com.tailscale.ipn.stdout.log";
  };
}
