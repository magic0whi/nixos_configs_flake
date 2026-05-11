{config, myvars, ...}: {
  networking.firewall = {
    allowedTCPPortRanges = [{ from = 11010; to = 11013;}]; allowedUDPPortRanges = [{ from = 11010; to = 11012;}];
  };
  sops = let
    restartUnits = map (name: "easytier-${name}.service") (builtins.attrNames config.services.easytier.instances);
    sopsFile = "${myvars.secrets_dir}/common.sops.yaml";
  in {
    secrets."easytier_network_secret" = {inherit sopsFile restartUnits;};
    secrets."easytier_peer_0" = {inherit sopsFile restartUnits;};
    templates."easytier.env" = {
      inherit restartUnits;
      content = ''
        ET_NETWORK_SECRET=${config.sops.placeholder.easytier_network_secret}
        # ET_PEERS uses comma delimiter
        ET_PEERS=udp://${config.sops.placeholder.easytier_peer_0}
      '';
    };
  };
  services.easytier = {
    enable = true;
    instances.main = {
      environmentFiles = [config.sops.templates."easytier.env".path];
      settings = {
        network_name = myvars.domain;
        ipv4 = "${myvars.networking.hosts_addr.${config.networking.hostName}.et_ipv4}/24";
        hostname = config.networking.hostName;
        peers = ["txt://txt.easytier.cn"];
        listeners = [
          "tcp://0.0.0.0:11010"
          "udp://0.0.0.0:11010"
          "wg://0.0.0.0:11011"
          "quic://0.0.0.0:11012"
          "ws://0.0.0.0:11011/"
          "wss://0.0.0.0:11012/"
          "faketcp://0.0.0.0:11013"
        ];
      };
      extraSettings = {
        ipv6 = "${myvars.networking.hosts_addr.${config.networking.hostName}.et_ipv6}/64";
        flags = {
          dev_name = "et-main";
          accept_dns = true; # Enable Magic DNS
          # relay_all_peer_rpc = true; # Help others hole punching
        };
        stun_servers = ["stun.miwifi.com" "stun.chat.bilibili.com"];
      };
    };
  };
}
