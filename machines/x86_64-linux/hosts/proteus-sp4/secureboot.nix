{pkgs, lib, lanzaboote, ...}: {
  imports = [lanzaboote.nixosModules.lanzaboote];
  environment.systemPackages = [
    pkgs.sbctl # For debugging and troubleshooting Secure Boot.
  ];
  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    # pkiBundle = "/etc/secureboot";
    pkiBundle = "/var/lib/sbctl";
  };
}
