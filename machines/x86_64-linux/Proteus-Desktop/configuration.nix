{myvars, config, ...}: {
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
  ## START systemd_tmpfiles.nix
  systemd.tmpfiles.rules = [
    # Grant 'rwx' to primary user via ACL. `getfacl /path` to show
    "A /mnt/storage/data - - - - u:${myvars.username}:rwx"
    # Optional: Default ACL so new files created there inherit these rights
    # A+: Adds an ACL entry to the existing ones
    "A+ /mnt/storage/data - - - - d:u:${myvars.username}:rwx"
  ];
  ## END systemd_tmpfiles.nix
  boot.binfmt.emulatedSystems = ["riscv64-linux"]; # Cross compilation
  ## START hostapd.nix
  age.secrets."proteus-ap.key" = {
    file = "${myvars.secrets_dir}/proteus-ap.key.age";
    mode = "0600"; owner = myvars.username;
  };
  services.hostapd = {
    # enable = true;
    radios.Proteus-AP = {
      band = "5g";
      channel = 0; # `0` use ACS
      countryCode = "GB";
      networks = {
        wlp2s0 = {
          ssid = "Proteus-AP";
          authentication = {
            pairwiseCiphers = ["GCMP" "GCMP-256"];
            saePasswordsFile = config.age.secrets."proteus-ap.key".path;
          };
        };
      };
    };
  };
  ## END hostapd.nix
}
