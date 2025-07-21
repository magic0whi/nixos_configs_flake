{mylib, myvars, ...}: {
  imports = mylib.scan_path ./.;
  # Customizing leaf packages via overlays has minimal impact on the Nix binary
  # cache, as these packages are not widely depended upon.
  nixpkgs.overlays = [(_: super: {
    catppuccin = super.catppuccin.override { # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ca/catppuccin/package.nix
      accent = myvars.catppuccin_accent;
      themeList = ["alacritty" "bat" "btop" "hyprland" "starship" "kvantum" "waybar"];
      variant = myvars.catppuccin_variant;
    };
    catppuccin-gtk = super.catppuccin-gtk.override { # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ca/catppuccin-gtk/package.nix
      accents = [myvars.catppuccin_accent];
      size = "compact";
      variant = myvars.catppuccin_variant;
    };
  })];
}
