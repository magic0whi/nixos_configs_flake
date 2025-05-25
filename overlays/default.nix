{pkgs, mylib, ...}: {
  imports = mylib.scan_path ./.;
  # nixpkgs.overlays = [(_: super: {
  #   nerd-font-patcher = super.nerd-font-patcher.overrideAttrs (_: _: rec {
  #     version = "3.3.0";
  #     src = pkgs.fetchzip {
  #       url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/FontPatcher.zip";
  #       sha256 = "sha256-/LbO8+ZPLFIUjtZHeyh6bQuplqRfR6SZRu9qPfVZ0Mw=";
  #       stripRoot = false;
  #     };
  #   });
  # })];
}
