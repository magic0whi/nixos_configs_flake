{config, pkgs, ...}: let
  cifs_opts = {
    fsType = "cifs";
    options = [
      "x-systemd.after=sing-box.service tailscaled.service,_netdev,nofail,seal,rw,relatime,vers=3.1.1,cache=strict,uid=1000,noforceuid,gid=1000,noforcegid,file_mode=0644,dir_mode=0755,iocharset=utf8,soft,nounix,serverino,mapposix,reparse=nfs,rsize=4194304,wsize=4194304,bsize=1048576,retrans=1,echo_interval=60,actimeo=1,closetimeo=1"
      "credentials=${config.age.secrets."proteus.smb".path}"
    ];
  };
in {
  environment.systemPackages = [pkgs.btrfs-progs];
  boot.supportedFilesystems = ["btrfs" "cifs"];
  fileSystems = {
    "/mnt/smb_cold_backup" = {device = "//proteusdesktop.tailba6c3f.ts.net/storage2";} // cifs_opts;
    "/mnt/storage3" = {device = "//proteusdesktop.tailba6c3f.ts.net/storage3";} // cifs_opts;
  };
}
