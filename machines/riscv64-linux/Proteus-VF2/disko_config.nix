{...}: let
  # LUKS-encrypted ZFS disk helper (460GB partition)
  mkLuksZfsDisk = diskId: {
    device = "/dev/disk/by-id/${diskId}";
    type = "disk";
    content = {
      type = "gpt";
      partitions.luks_part = {
        type = "CA7D7CCB-63ED-4C53-861C-1742536059CC";
        size = "488385536K"; # Unit is KiB, ~500G
        content = {
          type = "luks";
          name = "crypted-${diskId}";
          # passwordFile = "/tmp/dm_password.key";
          initrdUnlock = false;
          settings = { # boot.initrd.luks.device.<name>.*
            keyFile = "/etc/dm_keyfile.key";
            allowDiscards = true;
            bypassWorkqueues = true;
            # fallbackToPassword = false;
          };
          content = {
            type = "zfs";
            pool = "storage";
          };
        };
      };
    };
  };
in {
  disko.devices = {
    # --- 1. NVMe Root Drive (ZFS with Impermanence) ---
    disk = {
      nvme0 = {
        device = "/dev/disk/by-id/nvme-HP_SSD_EX900_250GB_HBSE28061201109";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "EFI SYSTEM PARTITION";
              # https://en.wikipedia.org/wiki/GUID_Partition_Table#Partition_type_GUIDs
              type = "C12A7328-F81F-11D2-BA4B-00A0C93EC93B";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                extraArgs = ["-F32" "-S4096" "-nBOOT"];
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            plain_swap = {
              label = "SWAP PARTITION";
              type = "0657FD6D-A4AB-43C4-84E5-0933C84B4F4F";
              size = "24G";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true;
              };
            };
            zfs_root = {
              label = "ZROOT PARTITION";
              type = "6A85CF4D-1DD2-11B2-99A6-080020736631";
              size = "100%";
              content = {type = "zfs"; pool = "zroot";};
            };
          };
        };
      };
      # --- 2. SATA Data Drives (LUKS + ZFS RAIDZ2) ---
      sata1 = mkLuksZfsDisk "ata-ST500DM002-1BD142_S2A7EA2P";
      sata2 = mkLuksZfsDisk "ata-WDC_WD5000AAKX-001CA0_WD-WMAYU5316042";
      sata3 = mkLuksZfsDisk "ata-WDC_WD5000AAKX-60U6AA0_WD-WCC2E3HEXA48";
      sata4 = mkLuksZfsDisk "ata-ST1000DM003-1CH162_S1DE5CWF";
      sata5 = mkLuksZfsDisk "ata-ST1000LM048-2E7172_WKPEZYSN";
      sata6 = mkLuksZfsDisk "ata-WDC_WD2002FYPS-02W3B0_WCAVY6186321";
    };
    # --- 3. ZFS Pools ---
    zpool = let
      type = "zpool";
      options.ashift = "12"; # Pool-level options
      rootFsOptions = { # Dataset defaults
        # ACL and Extended Attributes
        acltype = "posixacl";
        xattr = "sa";
        # Performance
        dnodesize = "auto";
        normalization = "formD";
        relatime = "on";

        compression = "zstd";

        devices = "off"; # Security
        # Mount behavior
        mountpoint = "none";
        canmount = "off";
      };
    in { # ROOT POOL (NVMe) - Impermanence Setup
      zroot = {
        inherit type options;
        mode = "";
        rootFsOptions = rootFsOptions // {mountpoint = "/";};
        postCreateHook = "zpool set bootfs=zroot/root zroot;"
        + "zpool set cachefile=/etc/zfs/zpool.cache zroot"; # Create zpool.cache
        datasets = {
          root = { # ROOT dataset (ephemeral, rolled back to blank on boot)
            type = "zfs_fs";
            mountpoint = "/";
            options."com.sun:auto-snapshot" = "false";
            postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot/root@blank$' || zfs snapshot zroot/root@blank";
          };
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
            # Used by `services.zfs.autoSnapshot.*` options.
            options."com.sun:auto-snapshot" = "true";
          };
          "home/root" = {
            type = "zfs_fs";
            mountpoint = "/root";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options."com.sun:auto-snapshot" = "false";
            options.atime = "off";
          };
          persistent = {
            type = "zfs_fs";
            mountpoint = "/persistent";
            options."com.sun:auto-snapshot" = "false";
          };
        };
      };
      storage = { # STORAGE POOL (SATA RAIDZ2)
        inherit type options rootFsOptions;
        mode = "raidz2";
        datasets.data = {
          type = "zfs_fs";
          mountpoint = "/mnt/storage/data";
          mountOptions = ["nofail"];
          options.canmount = "on";
        };
      };
    };
  };
}
