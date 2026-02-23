{myvars, config, ...}: let
  wlan_iface = "wlp0s20u9";
in {
  ## START sing-box.nix
  age.secrets."sb_client_linux.json" = {
    file = "${myvars.secrets_dir}/sb_client_linux.json.age";
    mode = "0000"; owner = "root";
  };
  networking.firewall = {
    allowedTCPPorts = [2080 9091]; # sing-box's WebUI
    allowedUDPPorts = [2080];
  };
  services.sing-box.enable = true;
  services.sing-box.config_file = config.age.secrets."sb_client_linux.json".path;
  ## END sing-box.nix
  ## START systemd_tmpfiles.nix
  systemd.tmpfiles.rules = [
    # Grant 'rwx' to primary user via ACL. `getfacl /path` to show
    "A /mnt/storage/data - - - - u:${myvars.username}:rwx"
    # Optional: Default ACL so new files created there inherit these rights
    # A+: Adds an ACL entry to the existing ones
    "A+ /mnt/storage/data - - - - d:u:${myvars.username}:rwx"
  ];
  ## END systemd_tmpfiles.nix
  boot.binfmt.emulatedSystems = ["riscv64-linux"]; # Cross compilation
  ## START hostapd.nix
  # boot.extraModulePackages = [config.boot.kernelPackages.rtl8812au];
  # boot.kernelModules = ["8812au"];
  # age.secrets."proteus-ap.key" = {
  #   file = "${myvars.secrets_dir}/proteus-ap.key.age";
  #   mode = "0600"; owner = myvars.username;
  # };
  # services.hostapd = {
  #   enable = true;
  #   radios.${wlan_iface} = {
  #     band = "2g"; # "5g" is `hw_mode=a`, "2g" is `hw_mode=g`
  #     channel = 7; # `0` use ACS
  #     countryCode = "US";
  #     wifi4.capabilities = [
  #       "HT40+"
  #       "SHORT-GI-20"
  #       "SHORT-GI-40"
  #       "RX-STBC1"
  #       "MAX-AMSDU-7935"
  #       "DSSS_CCK-40"
  #     ];
  #     # wifi5.operatingChannelWidth = "20or40"; # "80" doesn't start
  #     # wifi5.capabilities = [
  #     #   "MAX-MPDU-11454"
  #     #   "SHORT-GI-80"
  #     #   "TX-STBC-2BY1"
  #     #   "RX-STBC-1"
  #     #   "SU-BEAMFORMEE"
  #     #   "HTC-VHT"
  #     #   "MAX-A-MPDU-LEN-EXP3"
  #     # ];
  #     networks = {
  #       ${wlan_iface} = {
  #         ssid = "Proteus_5G";
  #         settings = {
  #           vht_oper_chwidth = "0";
  #           # vht_oper_centr_freq_seg0_idx = "42";
  #           ieee80211w = 0;
  #           ieee80211d = false;
  #           ieee80211h = false;
  #         };
  #         authentication = {
  #           mode = "none";
  #           # wpaPasswordFile = config.age.secrets."proteus-ap.key".path;
  #           # mode = "wpa3-sae";
  #           # saePasswords = [{passwordFile = config.age.secrets."proteus-ap.key".path;}];
  #         };
  #       };
  #     };
  #   };
  # };
  # networking.interfaces.${wlan_iface}.ipv4.addresses = [{
  #   address = "192.168.12.1";
  #   prefixLength = 24;
  # }];
  # # Tell systemd-resolved NOT to listen on port 53 (Stub Listener)
  # services.resolved.settings.Resolve.DNSStubListener = false;
  # # Ensure dnsmasq starts AFTER resolved to avoid race conditions
  # systemd.services.dnsmasq.after = ["systemd-resolved.service"];
  # services.dnsmasq = {
  #   enable = true;
  #   settings = {
  #     interface = wlan_iface;
  #     dhcp-range = ["192.168.12.10,192.168.12.240,12h"];
  #   };
  # };
  # networking.nat = {
  #   enable = true;
  #   # The interface connected to the internet (e.g., eth0, wlan0 onboard)
  #   externalInterface = myvars.networking.hosts_addr.${config.networking.hostName}.iface; 
  #   # The interface acting as the hotspot
  #   internalInterfaces = [wlan_iface];
  # };
  ## END hostapd.nix
}
