# NixOS Configurations Flake

Personal NixOS system configurations managed as a Flake, featuring declarative disk management, ZFS with impermanence, and LUKS encryption.

## Features

- **Declarative Disk Management**: Automated partitioning with [Disko](https://github.com/nix-community/disko)
- **ZFS Root with Impermanence**: Ephemeral root that rolls back to `zroot/root@blank` snapshot on boot
- **LUKS Encryption**: Full-disk encryption with systemd in initrd
- **Multi-Host Support**: Modular configuration for desktop and server systems
- **Persistent State Management**: Selective persistence with proper directory creation
- **Network Tunneling**: sing-box integration for secure networking

## Hosts

| Hostname | Type | Architecture | Storage |
|----------|------|--------------|---------|
| Proteus-Desktop | Workstation | x86_64-linux | ZFS on LUKS |
| Proteus-NUC | Home Server | x86_64-linux | ZFS on LUKS |
| Proteus-NixOS-* | VPS Instances | Vary | Btrfs |
| Proteus-VF2 | SBC | riscv64-linux | Btrfs (TODO) |

## Installation

### Prerequisites

- NixOS minimal installer ISO or [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)
- Target disk ID (e.g., `/dev/disk/by-id/*`)

### Steps

1. **Clone this repository:**
  ```bash
  git clone --depth=1 https://github.com/magic0whi/nixos_configs_flake.git
  cd nixos_configs_flake
  ```
2. **Review and customize disko configuration:**
  ```bash
  # Edit the disko config for your target host, update disk(s) ID with your actual hardware
  hx machines/<system>/<hostname>/disko-config.nix
  ```
3. **Generate & Modify `hardware-configuration.nix`**
  ```bash
  sudo nixos-generate-config --show-hardware-config
  ```
4. **Install NixOS:**
  ```bash
  sudo nixos-install --flake .#<hostname>
  ```
5. **Move critical files to `/mnt/persistent`:**
  ```bash
  sudo mv /mnt/etc/ssh/* /mnt/persistent/etc/ssh/
  sudo mv /mnt/etc/machine-id /mnt/persistent/etc/machine-id
  sudo mv /mnt/var/l{ib,og} /mnt/persistent/var/
  ```

Or use `nixos-anywhere` for unattended installation:
```bash
nix run nixpkgs#nixos-anywhere -- -f .#Proteus-NixOS-6 \
--phases kexec root@100.126.174.68 \
--kexec https://gh-proxy.org/https://github.com/nix-community/nixos-images/releases/download/nixos-25.05/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz
nix run nixpkgs#nixos-anywhere -- -f .#Proteus-NixOS-6 --phases disko --disko-mode format root@100.126.174.68
nix run nixpkgs#nixos-anywhere -- -f .#Proteus-NixOS-6 --phases disko --disko-mode mount root@100.126.174.68
nix run nixpkgs#nixos-anywhere -- -f .#Proteus-NixOS-6 --phases install root@100.126.174.68
# Check everything ok, then move critical files to `/mnt/persistent`, see above
# Finally reboot
nix run nixpkgs#nixos-anywhere -- -f .#Proteus-NixOS-6 --phases reboot root@100.126.174.68
```

## Usage

### Updating the system

```bash
nix flake update
just <host nickname>
```

### Remote deployment

```bash
deploy [-s] \
--targets /home/proteus/nixos_configs_flake#Proteus-NUC \
--targets /home/proteus/nixos_configs_flake#Proteus-Desktop \
--targets /home/proteus/nixos_configs_flake#Proteus-NixOS-1 \
--targets /home/proteus/nixos_configs_flake#Proteus-NixOS-2 \
--targets /home/proteus/nixos_configs_flake#Proteus-NixOS-3 \
--targets /home/proteus/nixos_configs_flake#Proteus-NixOS-4 \
--targets /home/proteus/nixos_configs_flake#Proteus-NixOS-5 \
--targets /home/proteus/nixos_configs_flake#Proteus-NixOS-6
```

### List ZFS volumes

```
zfs list -o name,mountpoint,encryption,canmount,mounted -t filesystem,snapshot
```

## Structure

TODO: TBD
```plaintext
.
├── flake.nix                  # Main flake configuration
├── flake.lock                 # Locked dependency versions
├── machines/<system>/
│   ├── Proteus-Desktop/
│   │   ├── configuration.nix  # Host-specific config
│   │   ├── hardware-configuration.nix
│   │   └── disko-config.nix   # Disk layout
│   └── Proteus-NUC/
│       ├── configuration.nix
│       ├── hardware-configuration.nix
│       └── disko-config.nix
├── modules/                   # Reusable NixOS modules
│   ├── common                 # Common shared modules
│   ├── nixos_headless/_impermanence.nix # Persistent directories config (default not included)
│   ├── *_hm_headless/         # Home-manager configurations (optional)
│   └── ...
```

## Key Design Decisions

### Ephemeral Root

The root filesystem (`zroot/root`) is rolled back to a blank snapshot on every boot via systemd in initrd. This ensures a clean slate while persistent data lives in `/persistent`.

```nix
boot.initrd.systemd.services."zfs-rollback-root" = {
  description = "Rollback zroot/root@blank in initrd";
  wantedBy = ["zfs-import.target"];
  after = ["zfs-import-zroot.service"]; # Make sure zroot is imported
  before = ["sysroot.mount"]; # Make sure this happens before root is mounted
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "${config.boot.zfs.package}/sbin/zfs rollback -r zroot/root@blank";
  };
};
```

### LUKS + ZFS

Each NVMe drive has a LUKS container, then ZFS pools are created across the unlocked devices for redundancy and flexibility (RAID-0 striping for performance or raidz2 for balanced performance & redundancy).

## License

MIT

## References

- [NixOS](https://nixos.org/) - Declarative Linux distribution
- [ZFS - Official NixOS Wiki](https://wiki.nixos.org/wiki/ZFS) - Copy-on-write filesystem with snapshots
- [Disko](https://github.com/nix-community/disko) - Declarative disk partitioning
- [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) - Install NixOS everywhere via SSH
- [impermanence](https://github.com/nix-community/impermanence) - Stateless root pattern
- [deploy-rs](https://github.com/serokell/deploy-rs) - A simple multi-profile Nix-flake deploy tool
- [sing-box](https://github.com/SagerNet/sing-box) - Universal transparent proxy platform
- [Graham Christensen's "Erase Your Darlings"](https://grahamc.com/blog/erase-your-darlings)

## Acknowledgments

Inspired by:
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/)
- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
