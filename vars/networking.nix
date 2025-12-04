_: { # TODO
  hosts_addr = {
    # ============================================
    # Homelab's Physical Machines (KubeVirt Nodes)
    # ============================================
    Proteus-NUC = { # Notebook
      iface = "wlo1";
      ipv4 = "100.109.224.13";
    };
    Proteus-Desktop.ipv4 = "192.168.1.23";

    # ============================================
    # Other VMs and Physical Machines
    # ============================================
    Proteus-NixOS-3.ipv4 = "100.65.115.97";
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
    Proteus-NixOS-3.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIApKI/t64l+gbXUkUgYaEmH5MibN7q6W2ZcreNaTjd6N proteus@Proteus-NixOS-3";
    Proteus-NixOS-4.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDR5ZoOvgTtQIgCv+Bt0gF9AlCUE0zM1sofmuZppWdaY root@Proteus-NixOS-4";
    Proteus-NixOS-5.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2kaT60FsFXcmFEUor9C5RgW10G5TZQEFvkeZeP03kv root@Proteus-NixOS-5";
  };
}
