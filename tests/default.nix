{pkgs}: {
  traffic-quota = pkgs.callPackage ./traffic-quota.nix {};

  # nix-darwin does not have a VM testing framework
  # easytier = pkgs.callPackage ./easytier.nix {};
}
