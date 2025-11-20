_: { # TODO
  hosts_addr = {
    # ============================================
    # Homelab's Physical Machines (KubeVirt Nodes)
    # ============================================
    kubevirt-shoryu = {
      iface = "eno1";
      ipv4 = "192.168.5.181";
    };

    # ============================================
    # Other VMs and Physical Machines
    # ============================================
    Proteus-NUC = { # Notebook
      iface = "wlo1";
      ipv4 = null;
    };
    nozomi = {
      # LicheePi 4A's wireless interface - RISC-V
      iface = "wlan0";
      ipv4 = "192.168.5.104";
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

    # ============================================
    # Kubernetes Clusters
    # ============================================
    k3s-prod-1-master-1 = { # VM
      iface = "enp2s0";
      ipv4 = "192.168.5.108";
    };
    k3s-prod-1-worker-1 = { # VM
      iface = "enp2s0";
      ipv4 = "192.168.5.111";
    };
    k3s-test-1-master-1 = { # KubeVirt VM
      iface = "enp2s0";
      ipv4 = "192.168.5.114";
    };
  };
  known_hosts = {
    Proteus-NUC.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILSH65JuZBQd6cPhSGMy+XpGoKBo+/HnUNrwAIb3YMO2 root@proteus-nuc";
    rakushun.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEOXFhFu9Duzp6ZBE288gDZ6VLrNaeWL4kDrFUh9Neic root@aquamarine";
  };
}
