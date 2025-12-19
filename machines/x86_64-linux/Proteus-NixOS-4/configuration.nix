{myvars, config, ...}: {
  time.timeZone = "Europe/London";
  boot.kernelParams = [
    "console=ttyS0,115200"
    "earlyprintk=ttyS0,115200"
    "consoleblank=0"
    "intel_iommu=off"
  ];
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
