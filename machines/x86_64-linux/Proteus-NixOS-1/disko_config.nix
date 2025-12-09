{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/scsi-3608e3e76dbf14034b65b53e2aaf666f6";
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
                extraArgs = ["-f"]; # Override existing partition
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
                  "@persistent" = {
                    mountpoint = "/persistent";
                    mountOptions = ["compress=zstd"];
                  };
                  # Subvolume for the swapfile
                  "@swap" = {
                    mountpoint = "/.swapvol";
                    mountOptions = ["compress=zstd" "noatime"];
                    swap.swapfile.size = "12G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
