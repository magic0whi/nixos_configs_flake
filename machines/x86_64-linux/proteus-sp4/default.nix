{inputs, lib, mylib, myvars, system}@args: let
  inherit (inputs) home-manager nixpkgs nixos-generators;
  hostname = "proteus-sp4";
  catppuccin_variant = "mocha";
  catppuccin_accent = "pink";
  myvars = let pkgs = nixpkgs.legacyPackages.${system}; in args.myvars // {
    inherit catppuccin_variant catppuccin_accent;
    catppuccin = pkgs.catppuccin.override { # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ca/catppuccin/package.nix
        accent = catppuccin_accent;
        themeList = ["alacritty" "bat" "btop" "hyprland" "starship" "kvantum" "waybar"];
        variant = catppuccin_variant;
    };
    catppuccin-gtk = pkgs.catppuccin-gtk.override { # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ca/catppuccin-gtk/package.nix
        accents = [catppuccin_accent];
        size = "compact";
        variant = catppuccin_variant;
    };
  };
  specialArgs = inputs // {inherit mylib myvars;};
  nixpkgs_modules = map mylib.relative_to_root [
    "modules/secrets"
    "overlays/nixpaks"
    "modules/nixos/common"
    "modules/nixos/desktop"
  ];
  hm_modules = map mylib.relative_to_root [
    "modules/hm/common"
    "modules/hm/desktop"
  ];
in {
  nixos_configurations = {
    "${hostname}" = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = nixpkgs_modules ++ [
        nixos-generators.nixosModules.all-formats
        {
          imports = [
            ./hardware-configuration.nix
            ./secureboot.nix
            ./impermanence.nix
            ./configuration.nix
            ./netdev-mount.nix
          ];
          networking.hostName = hostname;
        }
      ] ++ (lib.optionals ((lib.lists.length hm_modules) > 0) [
        home-manager.nixosModules.home-manager {
          home-manager.backupFileExtension = "home-manager.backup";
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."${myvars.username}".imports = hm_modules ++ [./hm];
        }
      ]);
    };
  };
  # generate iso image for hosts with desktop environment
  packages = {
    "${hostname}" = inputs.self.nixosConfigurations."${hostname}".config.formats.iso;
  };
}
