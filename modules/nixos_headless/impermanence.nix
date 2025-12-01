{myvars, lib, config, ...}: {
  # NOTE: Impermance can not coexist with nixos-generators, don't import this file if you wanna generate bootable iso
  # TIP: to show impermanence usage, run `sudo ncdu -x /`

  # There are two ways to clear the root filesystem on every boot:
  # 1. Use tmpfs for /
  # 2. (btrfs/zfs only) take a blank snapshot of the root filesystem and revert to it on every boot via:
  #   boot.initrd.postDeviceCommands = ''
  #     mkdir -p /run/mymount
  #     mount -o subvol=/ /dev/disk/by-uuid/UUID /run/mymount
  #     btrfs subvolume delete /run/mymount
  #     btrfs subvolume snapshot / /run/mymount
  #   '';
  #   See also https://grahamc.com/blog/erase-your-darlings/

  boot.initrd.systemd.enable = true; # Hibernate alse requires this
  # NOTE: impermanence only mounts the directory/file list below to /persistent. If the directory/file already exists in
  # the root filesystem, you should move those files/directories to /persistent first!
  environment.persistence."/persistent" = {
    # Sets the mount option x-gvfs-hide on all the bind mounts to hide them from the file manager
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
      "/etc/nix/inputs"

      "/var/log"
      "/var/lib"

    ]
    ++ lib.optional config.boot.lanzaboote.enable config.boot.lanzaboote.pkiBundle # If lanzaboote is enabled
    ++ lib.optional (config.age.secrets != {}) "/etc/agenix/"; # My secrets repo

    files = ["/etc/machine-id"];

    users.${myvars.username} = { # The following directories will be passed to /persistent/home/$USER
      directories = [
        "nixos_configs_flake"

        {directory = ".gnupg"; mode = "0700";}
        {directory = ".ssh"; mode = "0700";}

        # Misc
        ".config/pulse"
        ".pki"

        # Cloud native
        {directory = ".pulumi"; mode = "0700";} # pulumi - infrastructure as code
        {directory = ".aws"; mode = "0700";}
        {directory = ".docker"; mode = "0700";}
        {directory = ".kube"; mode = "0700";}

        # doom-emacs
        # ".config/emacs"

        # neovim / remmina / flatpak / ...
        ".local/share"
        ".local/state"

        # neovim plugins (wakatime & copilot)
        # ".wakatime"
        # ".config/github-copilot"
      ];
      # files = [".wakatime.cfg"];
    };
  };
}
