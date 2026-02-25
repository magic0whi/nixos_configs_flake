{myvars, ...}: {
  ## START services_monero.nix
  services.monero = {
    enable = true;
    dataDir = "/mnt/storage/data/monero";
    extraConfig = ''
      # log-file=/mnt/storage1/monero/monero.log
      # log-level=0
      p2p-use-ipv6=1
      rpc-use-ipv6=1
      public-node=1
      confirm-external-bind=1
      rpc-bind-ipv6-address=fd7a:115c:a1e0::d901:e013
    '';
    prune = true;
    rpc.address = myvars.networking.hosts_addr.Proteus-Desktop.ipv4;
    rpc.restricted = true;
  };
  ## END services_monero.nix
}
