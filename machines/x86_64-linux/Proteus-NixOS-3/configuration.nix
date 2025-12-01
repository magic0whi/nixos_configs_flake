{...}: {
  networking.firewall.enable = false;
  services.sing-box.enable = true;
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
  networking.useDHCP = false; # Disable global dhcpcd to avoid conflicts
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "en*"; # Matches your interface (e.g., ens3)
    networkConfig.DHCP = "yes";
    # Explicitly request DNS and Domains from DHCP
    dhcpV4Config.UseDomains = true; 
  };
}
