{mylib, pkgs, ...}: {
  imports = mylib.scan_path ./.;
  home.packages = with pkgs; [
    nvtopPackages.intel
    xmrig # Heating & Mining
  ];
}
