{inputs, lib, mylib, myvars, system}: let
  inherit (inputs) home-manager nixpkgs;
  specialArgs = inputs // {inherit mylib myvars;};
  name = "surfacepro4";
  nixpkgs_modules = map mylib.relative_to_root [
    "modules/nixos"
  ];
  hm_modules = map mylib.relative_to_root [
    "modules/hm/common.nix"
    "modules/hm/hyprland"
  ];
in {
  nixos_configurations = {
    # host with hyprland compositor
    "${name}" = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = nixpkgs_modules ++ [
        {
          imports = [
            ./secureboot.nix
            ./hardware-configuration.nix
            ./specs.nix
          ];
          # TODO: move to hosts
          modules.desktop.wayland.enable = true;
          # modules.secrets.desktop.enable = true;
          # modules.secrets.impermanence.enable = true;
        }
        # nixos-generators.nixosModules.all-formats
      ] ++ (lib.optionals ((lib.lists.length hm_modules) > 0) [
        home-manager.nixosModules.home-manager {
          home-manager.backupFileExtension = "home-manager.backup";
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."${myvars.username}".imports = hm_modules ++ [
            ./hm.nix
          ];
        }
      ]);
    };
  };
  # generate iso image for hosts with desktop environment
  # packages = {
    # "desktop-${name}" = inputs.self.nixosConfigurations."desktop-${name}".config.formats.iso;
  # };
}
