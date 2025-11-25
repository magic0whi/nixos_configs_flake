{...}: {
  networking.firewall.enable = false;
  services.sing-box.enable = true;
  time.timeZone = "Europe/London";
}
