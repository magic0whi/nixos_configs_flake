_: {
  hosts_addr = {
    # ============================================
    # Homelab's Physical Machines (KubeVirt Nodes)
    # ============================================
    Proteus-NUC = { # Notebook
      iface = "wlo1";
      ipv4 = "100.109.224.13";
    };
    Proteus-Desktop.ipv4 = "100.89.227.22";

    # ============================================
    # Other VMs and Physical Machines
    # ============================================
    Proteus-NixOS-1.ipv4 = "100.115.24.55";
    Proteus-NixOS-3.ipv4 = "100.95.194.59";
    Proteus-NixOS-4.ipv4 = "100.112.197.20";
    Proteus-NixOS-5.ipv4 = "100.81.108.101";
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
    Proteus-Desktop.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJla2bgFUIxlMyfqiS/BIxkFXFiIh4dhjjOvWzHnr6IL root@Proteus-Desktop";
    Proteus-NixOS-1.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOOpQ6Cn+3XpWzPH0OHhsyP7xovKJHbEaHQp+6dZ0ixs root@Proteus-NixOS-1";
    Proteus-NixOS-3.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINb46b7YcHOymx1UusNJJEw+2Q+dwdjzI0fhHn7U1iFE root@Proteus-NixOS-3";
    Proteus-NixOS-4.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDR5ZoOvgTtQIgCv+Bt0gF9AlCUE0zM1sofmuZppWdaY root@Proteus-NixOS-4";
    Proteus-NixOS-5.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2kaT60FsFXcmFEUor9C5RgW10G5TZQEFvkeZeP03kv root@Proteus-NixOS-5";
  };
}
