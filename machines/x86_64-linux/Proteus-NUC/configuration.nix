{pkgs, config, myvars, ...}: {
  time.timeZone = "Europe/London";
  age.identityPaths = ["/srv/sync_work/3keys/pgp2ssh.priv.key"];
  ## START iwd.nix
  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings.General.Country = "GB";
  systemd.services.iwd.serviceConfig.ExecStart = [
    "" # Leave a empty to remove previous ExecStarts
    "${config.networking.wireless.iwd.package}/libexec/iwd --nointerfaces 'wlan[0-9]'"
  ];
  systemd.network.links."80-iwd".enable = false; # Or
  # environment.etc."systemd/network/80-iwd.link".source = lib.mkForce (mylib.mk_out_of_store_symlink "/dev/null");
  ## END iwd.nix
  # virtualisation.docker.storageDriver = "btrfs"; # conflict with feature: containerd-snapshotter
  hardware.graphics.extraPackages = with pkgs; [intel-media-driver intel-compute-runtime-legacy1];
  environment.systemPackages = with pkgs; [
    bpftrace # powerful tracing tool, ref: https://github.com/bpftrace/bpftrace
  ];
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
  systemd.tmpfiles.rules = [ # See tmpfiles.d(5)
    # Type Path       Mode User    Group Age Argument
    "d /srv/sync      0775 proteus users -   -"
    "d /srv/sync_work 0775 proteus users -   -"
  ];
  ## END systemd_tmpfiles.nix
  boot.binfmt.emulatedSystems = ["riscv64-linux"]; # Cross compilation
  ## START sriov.nix
  boot.extraModulePackages = with pkgs; [i915-sriov xe-sriov];
  boot.kernelParams = [
    "intel_iommu=on"
    "xe.max_vfs=7"
    "xe.force_probe=0x9a60" # cat /sys/devices/pci0000:00/0000:00:02.0/device
    "module_blacklist=i915"
  ];
  ## END sriov.nix
}
