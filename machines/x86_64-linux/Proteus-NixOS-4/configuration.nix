{myvars, config, ...}: {
  time.timeZone = "Europe/London";
  boot.kernelParams = [
    "console=tty1"
    "console=ttyS0"
    # "nvme.shutdown_timeout=10" # The VM.Standard.E2.1.Micro does not use nvme
    "libiscsi.debug_libiscsi_eh=1"
    "crash_kexec_post_notifiers"
  ];
  # services.cloud-init = {
  #   enable = true;
  #   network.enable = true; # Let cloud-init manage networking/DNS
  #   settings = {
  #     preserve_hostname = true; # Let NixOS manage hostname
  #     manage_etc_hosts = false; # Let NixOS manage /etc/hosts
  #     datasource_list = ["Oracle"];
  #   };
  # };
  networking.useDHCP = true;
  services.syncthing.enable = false;
  ## START sing-box.nix
  age.secrets."sb_Proteus-NixOS-3.json" = {
    file = "${myvars.secrets_dir}/sb_Proteus-NixOS-3.json.age";
    mode = "0000";
    owner = "root";
  };
  networking.firewall = {allowedTCPPorts = [443];}; # Reality
  services.sing-box.enable = true;
  services.sing-box.config_file = config.age.secrets."sb_Proteus-NixOS-3.json".path;
  ## END sing-box.nix
}
