{myvars, config, ...}: let
  iface_wlan = myvars.networking.hosts_addr.${config.networking.hostName}.iface_wlan;
in {
  ## START sing-box.nix
  age.secrets."sb_client_linux.json" = {
    file = "${myvars.secrets_dir}/sb_client_linux.json.age";
    mode = "0000"; owner = "root";
  };
  services.sing-box.enable = true;
  services.sing-box.config_file = config.age.secrets."sb_client_linux.json".path;
  ## END sing-box.nix
  ## START systemd_tmpfiles.nix
  systemd.tmpfiles.rules = [
    # Grant 'rwx' to primary user via ACL. `getfacl /path` to show
    "A ${myvars.storage_path} - - - - u:${myvars.username}:rwx"
    # Optional: Default ACL so new files created there inherit these rights
    # A+: Adds an ACL entry to the existing ones
    "A+ ${myvars.storage_path} - - - - d:u:${myvars.username}:rwx"
  ];
  ## END systemd_tmpfiles.nix
  boot.binfmt.emulatedSystems = ["riscv64-linux"]; # Cross compilation
  ## START hostapd.nix
  boot.extraModulePackages = [config.boot.kernelPackages.rtl8812au];
  boot.kernelModules = ["8812au"];
  age.secrets."proteus-ap.key" = {
    file = "${myvars.secrets_dir}/proteus-ap.key.age";
    mode = "0600"; owner = myvars.username;
  };
  services.hostapd = {
    enable = true;
    radios.${iface_wlan} = {
      band = "2g"; # "5g" is `hw_mode=a`, "2g" is `hw_mode=g`
      channel = 7; # `0` use ACS
      countryCode = "US";
      wifi4.capabilities = [
        "HT40+"
        "SHORT-GI-20"
        "SHORT-GI-40"
        "RX-STBC1"
        "MAX-AMSDU-7935"
        "DSSS_CCK-40"
      ];
      # wifi5.operatingChannelWidth = "20or40"; # "80" doesn't start
      # wifi5.capabilities = [
      #   "MAX-MPDU-11454"
      #   "SHORT-GI-80"
      #   "TX-STBC-2BY1"
      #   "RX-STBC-1"
      #   "SU-BEAMFORMEE"
      #   "HTC-VHT"
      #   "MAX-A-MPDU-LEN-EXP3"
      # ];
      networks = {
        ${iface_wlan} = {
          ssid = "Proteus_5G";
          settings = {
            vht_oper_chwidth = "0";
            # vht_oper_centr_freq_seg0_idx = "42";
            ieee80211w = 0;
            ieee80211d = false;
            ieee80211h = false;
          };
          authentication = {
            mode = "none";
            # wpaPasswordFile = config.age.secrets."proteus-ap.key".path;
            # mode = "wpa3-sae";
            # saePasswords = [{passwordFile = config.age.secrets."proteus-ap.key".path;}];
          };
        };
      };
    };
  };
  networking.interfaces.${iface_wlan}.ipv4.addresses = [{
    address = "192.168.12.1";
    prefixLength = 24;
  }];
  networking.nftables.tables.bypass_hostapd = {
    family = "inet";
    content = ''
      chain prerouting {
        type filter hook prerouting priority dstnat - 5; policy accept;

        # 1. Do NOT bypass FakeIP traffic. Let sing-box handle it.
        ip daddr 198.18.0.0/15 return

        # 2. Bypass everything else from hostapd managed iface
        ip saddr ${(builtins.head config.networking.interfaces.${iface_wlan}.ipv4.addresses).address} ct mark set 0x00002024
      }
    '';
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${(builtins.head config.networking.interfaces.${iface_wlan}.ipv4.addresses).address} accept comment "Allow hostapd clients to reach auto_redirect ports"
  '';
  # We can keep systemd-resolved listening on 127.0.0.53:53 and
  # use dnsmasq solely on the wlan interface by telling it to only bind there.
  # This prevents conflicts with systemd-resolved!
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = iface_wlan;
      bind-interfaces = true;
      dhcp-range = ["192.168.12.10,192.168.12.240,12h"];
      # Tell DHCP clients to use 223.5.5.5 as their DNS server
      dhcp-option = ["option:dns-server,223.5.5.5"];
    };
  };
  networking.nat = {
    enable = true;
    # The interface connected to the internet (e.g., eth0, wlan0 onboard)
    externalInterface = myvars.networking.hosts_addr.${config.networking.hostName}.iface;
    # The interface acting as the hotspot
    internalInterfaces = [iface_wlan];
  };
  ## END hostapd.nix
}
