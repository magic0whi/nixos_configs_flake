{pkgs}: {
  traffic-quota = pkgs.callPackage ./traffic-quota.nix {};

  # Future tests:
  # easytier = pkgs.callPackage ./easytier.nix {};
}
