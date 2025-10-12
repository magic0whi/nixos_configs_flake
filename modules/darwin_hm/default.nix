{config, lib, mylib, pkgs, ...}: {
  imports = mylib.scan_path ./.;
  home.packages = with pkgs; [
    iproute2mac
    utm # Virtual machine manager for Apple platforms
  ];
  ## START xdg.nix
  xdg.enable = true; # Enable management of XDG base directories on macOS
  ## END xdg.nix
  ## START shell.nix
  home.shellAliases = {
    Ci = "pbcopy";
    Co = "pbpaste";
  };
  ## END shell.nix
  ## START gpg.nix
  # Don't bootout the 'system/com.openssh.ssh-agent', as it seizes the '$SSH_AUTH_SOCK'
  home.sessionVariablesExtra = ''
    export SSH_AUTH_SOCK="$(${config.programs.gpg.package}/bin/gpgconf --list-dirs agent-ssh-socket)"
  '';
  # launchd.agents.gpg-agent.config = { # Enable logs for debugging
  #   StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/gnupg-agent.stderr.log";
  #   StandardOutPath = "${config.home.homeDirectory}/Library/Logs/gnupg-agent.stdout.log";
  # };
  ## END gpg.nix
  ## START associations.nix
  home.activation.set_mpv_associations = (lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Set UTIs
    ${lib.getExe' pkgs.duti "duti"} -s io.mpv public.movie viewer
    # Set file extensions
    ${lib.getExe' pkgs.duti "duti"} -s io.mpv .mkv viewer
    ${lib.getExe' pkgs.duti "duti"} -s io.mpv .mp4 viewer
    ${lib.getExe' pkgs.duti "duti"} -s com.google.Chrome .webm viewer
  '');
  ## END associations.nix
  ## START syncthing.nix
  # Don't create default ~/Sync folder
  launchd.agents.syncthing.config.EnvironmentVariables.STNODEFAULTFOLDER = "true";
  ## END syncthing.nix
}
