{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:00:04.0-scsi-0:0:0:1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              label = "EFI SYSTEM PARTITION";
              type = "C12A7328-F81F-11D2-BA4B-00A0C93EC93B";
              size = "512M";
              content = {
                type = "filesystem";
                mountpoint = "/boot";
                format = "vfat";
                extraArgs = ["-F32" "-S4096" "-nBOOT"];
                mountOptions = ["umask=0077"];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  # Subvolume name is different from mountpoint
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd"];
                  };
                  # Subvolume name is the same as the mountpoint
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = ["compress=zstd"];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  # Subvolume for the swapfile
                  "@swap" = {
                    mountpoint = "/.swapvol";
                    mountOptions = ["compress=zstd" "noatime"];
                    swap = {
                      swapfile.size = "1G";
                      # swapfile2.size = "20M";
                      # swapfile2.path = "rel-path";
                    };
                  };
                };
                # mountpoint = "/btrfs-root";
                # swap = { # swapfiles under `/btrfs-root`
                #   swapfile.size = "20M";
                #   swapfile1.size = "20M";
                # };
              };
            };
          };
        };
      };
    };
  };
}
