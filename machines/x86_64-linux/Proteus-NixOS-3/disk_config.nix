{
  disko.devices = {
    disk = {
      a = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:00:04.0-scsi-0:0:0:1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "EFI system partition";
              size = "512M";
              # https://en.wikipedia.org/wiki/GUID_Partition_Table#Partition_type_GUIDs
              # https://github.com/nix-community/disko/blob/ff2d853a8451a802786878e70324a4781d40d62d/lib/types/gpt.nix#L32
              type = "C12A7328-F81F-11D2-BA4B-00A0C93EC93B";
              content = {
                # https://github.com/nix-community/disko/blob/ff2d853a8451a802786878e70324a4781d40d62d/lib/types/filesystem.nix
                type = "filesystem";
                format = "vfat";
                extraArgs = ["-F32" "-S4096"];
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            plainSwap = {
              label = "swap partition";
              size = "1G";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true; # resume from hiberation from this device
              };
            };
            zfs = {
              size = "100%";
              type = "6A85CF4D-1DD2-11B2-99A6-080020736631";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        mode = "";
        options = {
          ashift = "12";
          cachefile = "/etc/zfs/zpool.cache"; # Workaround: cannot import 'zroot': I/O error in disko tests
        };
        rootFsOptions = {
          acltype = "posix";
          relatime = "on";
          xattr = "sa";
          dnodesize = "auto";
          normalization = "formD";
          canmount = "off";
          devices = "off";
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = "/";
        postCreateHook = ''
          zpool set bootfs=zroot/default zroot
          zpool list -o name,size,health,altroot,cachefile,bootfs
          '';
        datasets = {
          default = {type = "zfs_fs"; options.mountpoint = "/";};
          nix.type = "zfs_fs";
          home.type = "zfs_fs";
          "home/root" = {type = "zfs_fs"; options.mountpoint = "/root";};
        };
      };
    };
  };
}
