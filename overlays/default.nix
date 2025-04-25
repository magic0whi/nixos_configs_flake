# _: {
#   nixpkgs.overlays = [(_: super: {
#     catppuccin-gtk = super.catppuccin-gtk.override { # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ca/catppuccin-gtk/package.nix
#       accents = ["pink"];
#       size = "compact";
#       variant = "macchiato";
#     };
#   })];
# }
{}
