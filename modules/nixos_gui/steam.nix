{pkgs, ...}: {
  programs.steam = {
    enable = pkgs.stdenv.isx86_64;
  };
}

