_: {
  hosts_addr = {
    "github.com".ipv4 = null;
    "ssh.github.com".ipv4 = null;
    # ============================================
    # Homelab's Physical Machines (KubeVirt Nodes)
    # ============================================
    Proteus-MBP14M4P.ipv4 = "100.109.173.125";
    Proteus-NUC = {/* Notebook */iface = "wlo1"; ipv4 = "100.64.161.20";};
    Proteus-Desktop.ipv4 = "100.89.227.22";

    # ============================================
    # Other VMs and Physical Machines
    # ============================================
    Proteus-NixOS-1.ipv4 = "100.74.72.29";
    Proteus-NixOS-2.ipv4 = "100.103.95.67";
    Proteus-NixOS-3.ipv4 = "100.115.240.107";
    Proteus-NixOS-4.ipv4 = "100.111.165.94";
    Proteus-NixOS-5.ipv4 = "100.125.56.30";
    Proteus-NixOS-6.ipv4 = "100.126.174.68";
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
  known_hosts = let
    github_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  in {
    "github.com".public_key = github_key;
    "ssh.github.com".public_key = github_key;
    Proteus-MBP14M4P.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+ekT5jrD2KuLEqVeIASQ9A/VaBcrCE7xfcBqxsWbQ8";
    Proteus-NUC.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGkreuZakzaKdfQL+YNAvcr6WRsIz5c3eoFcK3NAUmLu root@Proteus-NUC";
    Proteus-Desktop.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJla2bgFUIxlMyfqiS/BIxkFXFiIh4dhjjOvWzHnr6IL root@Proteus-Desktop";
    Proteus-NixOS-1.public_key =  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqgfVyb6hCdQmzbls0NNjMJ6Zxp3zq+XClR1OZIPnCD root@Proteus-NixOS-1";
    Proteus-NixOS-2.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM1+VCgRXwuoKpKGMBSDdcCeTyVj8Z0jL056tmKM+Rxg root@Proteus-NixOS-2";
    Proteus-NixOS-3.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGj2Cf9faGKcaakEsBRCAGUaj42zYpjJPjycHeqhxdxK root@Proteus-NixOS-3";
    Proteus-NixOS-4.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC0ZPECWe2QmB5QqQhBIloXP8lkpBEhpcUPnnVIuKbNU root@Proteus-NixOS-4";
    Proteus-NixOS-5.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILKbjjsPGhQrkrH5HKXMR6rTRJ3pV5+a9ca7GvQ7GvsH root@Proteus-NixOS-5";
    Proteus-NixOS-6.public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOUXCE7Ghu4cLl0xBCg+q69QqGuhyIu17KDgrCpz0Gvb root@Proteus-NixOS-6";
  };
}
