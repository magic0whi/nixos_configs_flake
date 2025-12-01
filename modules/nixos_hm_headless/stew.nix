{myvars, ...}: {
  ## START syncthing.nix
  # Don't create default ~/Sync folder
  systemd.user.services."${myvars.username}".environment.STNODEFAULTFOLDER = "true";
  ## END syncthing.nix
}
