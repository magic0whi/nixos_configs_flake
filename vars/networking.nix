_: { # TODO
  hosts_addr = {
    # ============================================
    # Homelab's Physical Machines (KubeVirt Nodes)
    # ============================================
    kubevirt-shoryu = {
      iface = "eno1";
      ipv4 = "192.168.5.181";
    };
    kubevirt-shushou = {
      iface = "eno1";
      ipv4 = "192.168.5.182";
    };
    kubevirt-youko = {
      iface = "eno1";
      ipv4 = "192.168.5.183";
    };

    # ============================================
    # Other VMs and Physical Machines
    # ============================================
    ai = {
      # Desktop PC
      iface = "enp5s0";
      ipv4 = "192.168.5.100";
    };
    aquamarine = {
      # VM
      iface = "enp2s0";
      ipv4 = "192.168.5.101";
    };
    ruby = {
      # VM
      iface = "enp2s0";
      ipv4 = "192.168.5.102";
    };
    kana = {
      # VM
      iface = "enp2s0";
      ipv4 = "192.168.5.103";
    };
    nozomi = {
      # LicheePi 4A's wireless interface - RISC-V
      iface = "wlan0";
      ipv4 = "192.168.5.104";
    };
    yukina = {
      # LicheePi 4A's wireless interface - RISC-V
      iface = "wlan0";
      ipv4 = "192.168.5.105";
    };
    chiaya = {
      # VM
      iface = "enp2s0";
      ipv4 = "192.168.5.106";
    };
    suzu = {
      # Orange Pi 5 - ARM
      iface = "end1";
      ipv4 = "192.168.5.107";
    };
    rakushun = {
      # Orange Pi 5 - ARM
      # RJ45 port 1 - enP4p65s0
      # RJ45 port 2 - enP3p49s0
      iface = "enP4p65s0";
      ipv4 = "192.168.5.179";
    };
    suzi = {
      iface = "enp2s0"; # fake iface, it's not used by the host
      ipv4 = "192.168.5.178";
    };
    mitsuha = {
      iface = "enp2s0"; # fake iface, it's not used by the host
      ipv4 = "192.168.5.177";
    };

    # ============================================
    # Kubernetes Clusters
    # ============================================
    k3s-prod-1-master-1 = {
      # VM
      iface = "enp2s0";
      ipv4 = "192.168.5.108";
    };
    k3s-prod-1-master-2 = {
      # VM
      iface = "enp2s0";
      ipv4 = "192.168.5.109";
    };
    k3s-prod-1-master-3 = {
      # VM
      iface = "enp2s0";
      ipv4 = "192.168.5.110";
    };
    k3s-prod-1-worker-1 = {
      # VM
      iface = "enp2s0";
      ipv4 = "192.168.5.111";
    };
    k3s-prod-1-worker-2 = {
      # VM
      iface = "enp2s0";
      ipv4 = "192.168.5.112";
    };
    k3s-prod-1-worker-3 = {
      # VM
      iface = "enp2s0";
      ipv4 = "192.168.5.113";
    };

    k3s-test-1-master-1 = {
      # KubeVirt VM
      iface = "enp2s0";
      ipv4 = "192.168.5.114";
    };
    k3s-test-1-master-2 = {
      # KubeVirt VM
      iface = "enp2s0";
      ipv4 = "192.168.5.115";
    };
    k3s-test-1-master-3 = {
      # KubeVirt VM
      iface = "enp2s0";
      ipv4 = "192.168.5.116";
    };
  };
  known_hosts = {
    aquamarine.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEOXFhFu9Duzp6ZBE288gDZ6VLrNaeWL4kDrFUh9Neic root@aquamarine";
    # ruby.public_key = "";
    # kana.public_key = "";
  };
}
