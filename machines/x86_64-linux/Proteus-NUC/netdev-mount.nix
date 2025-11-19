{config, myvars, pkgs, ...}: let
  cifs_opts = {
    fsType = "smb3";
    options = [
      "x-systemd.requires=tailscaled.service"
      "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s"
      "relatime,seal,rw,vers=3.1.1,cache=strict,uid=${toString config.users.users.${myvars.username}.uid},noforceuid,gid=${toString config.users.groups.${myvars.username}.gid},noforcegid,file_mode=0644,dir_mode=0755,iocharset=utf8,nounix,serverino,mapposix,rsize=4194304,wsize=4194304,bsize=1048576"
      "credentials=${config.age.secrets."proteus.smb".path}"
    ];
  };
in {
  environment.systemPackages = with pkgs; [btrfs-progs cifs-utils];
  boot.supportedFilesystems = ["cifs"];
  fileSystems = {
    # "/mnt/storage2" = {device = "//proteusdesktop.tailba6c3f.ts.net/storage2";} // cifs_opts;
    # "/mnt/storage3" = {device = "//proteusdesktop.tailba6c3f.ts.net/storage3";} // cifs_opts;
  };
}
