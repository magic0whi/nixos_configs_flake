{
  boot.blacklistedKernelModules = ["nova_core"];
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    dynamicBoost.enable = true;
    open = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    prime = {
      # NOTE: Don't use sync.enable for hybrid laptop
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      offload.enable = true;
      offload.enableOffloadCmd = true;
    };
  };
}
