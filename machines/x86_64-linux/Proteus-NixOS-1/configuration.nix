{pkgs, lib, mylib, config, ...}: {
  time.timeZone = "Europe/Berlin";
  services.sing-box.enable = false;
}
