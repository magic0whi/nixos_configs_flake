{pkgs, lib, mylib, config, ...}: {
  modules.desktop.wayland.enable = true;
  modules.secrets.desktop.enable = true;
  networking.wireless.iwd.enable = true;
  systemd.services.iwd.serviceConfig.ExecStart = [
    ""
    "${config.networking.wireless.iwd.package}/libexec/iwd --nointerfaces 'wlan[0-9]'"
  ];
  systemd.network.links."80-iwd".enable = false; # Or
  # environment.etc."systemd/network/80-iwd.link".source = lib.mkForce (mylib.mk_out_of_store_symlink "/dev/null");
  # virtualisation.docker.storageDriver = "btrfs"; # conflict with feature: containerd-snapshotter
  hardware.graphics.extraPackages = with pkgs; [intel-media-driver intel-compute-runtime-legacy1];
  time.timeZone = "Europe/Berlin";
}
