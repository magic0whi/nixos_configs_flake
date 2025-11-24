{lib, config, ...}: {
  networking.firewall.allowedTCPPorts = [9091]; # sing-box WebUI
  # Override the sing-box's systemd service
  systemd.services.sing-box = lib.mkIf config.services.sing-box.enable (lib.mkOverride 100 {
    serviceConfig = {
      StateDirectory = "sing-box";
      StateDirectoryMode = "0700";
      RuntimeDirectory = "sing-box";
      RuntimeDirectoryMode = "0700";
      LoadCredential = [("config.json:" + config.age.secrets."config.json".path)];
      ExecStart = [
        "" # Empty value remove previous value
        (let configArgs = "-c $\{CREDENTIALS_DIRECTORY}/config.json";
          in "${lib.getExe config.services.sing-box.package} -D \${STATE_DIRECTORY} ${configArgs} run")
      ];
    };
    wantedBy = ["multi-user.target"];
  });
}
