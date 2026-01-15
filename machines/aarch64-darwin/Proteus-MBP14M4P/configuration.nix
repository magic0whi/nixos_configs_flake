{myvars, config, ...}: {
  time.timeZone = "Europe/London";
  age.secrets."sb_client.json" = {
    file = "${myvars.secrets_dir}/sb_client.json.age";
    mode = "0000";
    owner = "root";
  };
  services.sing-box.enable = true;
  services.sing-box.config_file = config.age.secrets."sb_client.json".path;
}
