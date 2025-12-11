{myvars, config, ...}: {
  ## START sing-box.nix
  age.secrets."sb_client.json" = {
    file = "${myvars.secrets_dir}/sb_client.json.age";
    mode = "0000";
    owner = "root";
  };
  networking.firewall = {
    allowedTCPPorts = [2080 9091]; # sing-box's WebUI
    allowedUDPPorts = [2080];
  };
  services.sing-box.enable = true;
  services.sing-box.config_file = config.age.secrets."sb_client.json".path;
  ## END sing-box.nix
  ## START acl.nix
  systemd.tmpfiles.rules = [
    # Grant 'rwx' to primary user via ACL. `getfacl /path` to show
    "A /mnt/storage/data - - - - u:${myvars.username}:rwx"
    # Optional: Default ACL so new files created there inherit these rights
    # A+: Adds an ACL entry to the existing ones
    "A+ /mnt/storage/data - - - - d:u:${myvars.username}:rwx"
    (if (config.environment ? persistence && config.environment.persistence != {}) then
      "A+ /persistent/etc/ssh/ssh_host_ed25519_key - - - - u:${myvars.username}:r--"
    else
      "A+ /etc/ssh/ssh_host_ed25519_key - - - - u:${myvars.username}:r--"
    )
  ];
  ## END acl.nix
}
