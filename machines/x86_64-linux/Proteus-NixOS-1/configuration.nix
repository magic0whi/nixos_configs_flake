{myvars, config, ...}: {
  time.timeZone = "Asia/Taipei";
  boot.kernelParams = [
    "console=ttyS0,115200"
    "earlyprintk=ttyS0,115200"
    "consoleblank=0"
    "intel_iommu=off"
  ];
  # services.cloud-init = {
  #   enable = true;
  #   network.enable = true; # Let cloud-init manage networking/DNS
  #   settings = {
  #     preserve_hostname = true; # Let NixOS manage hostname
  #     manage_etc_hosts = false; # Let NixOS manage /etc/hosts
  #     datasource_list = ["GCE"];
  #   };
  # };
  # networking.useDHCP = false;
  services.syncthing.enable = false;
  ## START sing-box.nix
  age.secrets."sb_Proteus-NixOS-1.json" = {
    file = "${myvars.secrets_dir}/sb_Proteus-NixOS-1.json.age";
    mode = "0000"; owner = "root";
  };
  networking.firewall = {allowedTCPPorts = [443];}; # Reality
  services.sing-box.enable = true;
  services.sing-box.config_file = config.age.secrets."sb_Proteus-NixOS-1.json".path;
  ## END sing-box.nix
}
