{myvars, ...}: {
  ## START syncthing.nix
  # Don't create default ~/Sync folder
  systemd.user.services."${myvars.username}".environment.STNODEFAULTFOLDER = "true";
  ## END syncthing.nix
  ## START peripherals.nix
  services.udiskie.enable = true; # Auto mount usb drives
  ## END peripherals.nix
}
