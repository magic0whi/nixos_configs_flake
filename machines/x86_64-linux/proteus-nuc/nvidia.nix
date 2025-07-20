{
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    dynamicBoost.enable = true;
    open = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    prime.intelBusId = "PCI:0:2:0";
    prime.nvidiaBusId = "PCI:1:0:0";
    prime.offload.enable = true;
    prime.offload.enableOffloadCmd = true;
  };
}
