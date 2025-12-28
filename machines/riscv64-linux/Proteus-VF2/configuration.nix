{myvars, config, ...}: {
  ## START iwd.nix
  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings.General.Country = "CN";
  systemd.services.iwd.serviceConfig.ExecStart = [
    "" # Leave a empty to remove previous ExecStarts
    "${config.networking.wireless.iwd.package}/libexec/iwd --nointerfaces 'wlan[0-9]'"
  ];
  systemd.network.links."80-iwd".enable = false;
  ## END iwd.nix
  ## START sing-box.nix
  age.secrets."sb_client.json" = {
    file = "${myvars.secrets_dir}/sb_client.json.age";
    mode = "0000"; owner = "root";
  };
  networking.firewall = {
    allowedTCPPorts = [2080 9091]; # sing-box's WebUI
    allowedUDPPorts = [2080];
  };
  services.sing-box.enable = true;
  services.sing-box.config_file = config.age.secrets."sb_client.json".path;
  ## END sing-box.nix
  catppuccin.enable = false;
}
