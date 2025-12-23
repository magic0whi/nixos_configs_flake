{myvars, config, ...}: {
  time.timeZone = "Asia/Shanghai";
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.systemd-boot.enable = false;
  boot.kernelParams = [
    "net.ifnames=0"
    "consoleblank=600"
    "console=tty0"
    "console=ttyS0,115200n8"
    "noibrs"
    # "crashkernel=0M-1G:0M,1G-4G:192M,4G-128G:384M,128G-:512M"
  ];
  services.syncthing.enable = false;
  ## START sing-box.nix
  age.secrets."sb_Proteus-NixOS-6.json" = {
    file = "${myvars.secrets_dir}/sb_Proteus-NixOS-6.json.age";
    mode = "0000"; owner = "root";
  };
  networking.firewall = {allowedTCPPorts = [443];}; # Reality
  services.sing-box.enable = true;
  services.sing-box.config_file = config.age.secrets."sb_Proteus-NixOS-6.json".path;
  ## END sing-box.nix
  boot.binfmt.emulatedSystems = ["riscv64-linux"]; # Cross compilation
}
