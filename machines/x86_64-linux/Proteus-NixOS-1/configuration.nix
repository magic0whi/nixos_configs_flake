{...}: {
  networking.firewall.enable = false;
  services.sing-box.enable = false;
  time.timeZone = "Europe/Berlin";
}
