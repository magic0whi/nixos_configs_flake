{pkgs, config, myvars, ...}: {
  age.identityPaths = ["/srv/sync_work/3keys/pgp2ssh.priv.key"];
  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings.General.Country = "CN";
  systemd.services.iwd.serviceConfig.ExecStart = [
    "" # Leave a empty to remove previous ExecStarts
    "${config.networking.wireless.iwd.package}/libexec/iwd --nointerfaces 'wlan[0-9]'"
  ];
  systemd.network.links."80-iwd".enable = false; # Or
  # environment.etc."systemd/network/80-iwd.link".source = lib.mkForce (mylib.mk_out_of_store_symlink "/dev/null");
  # virtualisation.docker.storageDriver = "btrfs"; # conflict with feature: containerd-snapshotter
  hardware.graphics.extraPackages = with pkgs; [intel-media-driver intel-compute-runtime-legacy1];
  environment.systemPackages = with pkgs; [
    bpftrace # powerful tracing tool, ref: https://github.com/bpftrace/bpftrace
  ];
  ## START sing-box.nix
  age.secrets."sb_client.json" = {
    file = "${myvars.secrets_dir}/sb_client.json.age";
    mode = "0000";
    owner = "root";
  };
  networking.firewall = {allowedTCPPorts = [9091];}; # sing-box's WebUI
  services.sing-box.enable = true;
  services.sing-box.config_file = config.age.secrets."sb_client.json".path;
  ## END sing-box.nix
}
