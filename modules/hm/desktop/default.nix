{mylib, lib, pkgs, ...}: with lib; {
  imports = mylib.scan_path ./.;
  fonts.fontconfig.enable = mkOverride 999 false; # This allows fontconfig to discover fonts and configurations installed through home.packages, but I manage fonts at system-level, not user-level
  services.gpg-agent.pinentry.package = mkOverride 999 pkgs.pinentry-qt; # gpg agent with pinentry-qt
}
