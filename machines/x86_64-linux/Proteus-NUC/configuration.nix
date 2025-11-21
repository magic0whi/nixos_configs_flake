{pkgs, config, ...}: {
  modules.secrets.desktop.enable = true;
  age.identityPaths = ["/srv/sync_work/3keys/private/pgp2ssh.key"];
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
}
