{mylib, pkgs, ...}: {
  imports = mylib.scan_path ./.;
  home.packages = [pkgs.nvtopPackages.intel];
}
