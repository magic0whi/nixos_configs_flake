{mylib, pkgs, ...}: {
  imports = mylib.scan_path ./.;
  home.packages = [pkgs.nvtopPackages.intel];
  programs.starship.catppuccin.enable = false; # Build failed
}
