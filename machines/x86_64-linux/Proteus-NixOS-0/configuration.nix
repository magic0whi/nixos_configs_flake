{myvars, config, ...}: {
  time.timeZone = "America/Los_Angeles";
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
  services.traffic-quota.enable = true;
  ## START sing-box.nix
  sops.secrets."sb_Proteus-NixOS-1.json" = {
    sopsFile = "${myvars.secrets_dir}/sb_Proteus-NixOS-1.json.sops";
    format = "binary";
    restartUnits = ["sing-box.service"];
  };
  networking.firewall.allowedTCPPorts = [443]; # Reality
  services.sing-box.enable = true;
  services.sing-box.configFile = config.sops.secrets."sb_Proteus-NixOS-1.json".path;
  ## END sing-box.nix
  boot.binfmt.emulatedSystems = ["riscv64-linux"]; # Cross compilation
}
