{inputs, lib, mylib, myvars, system}: let
  inherit (inputs) home-manager nixpkgs nixos-generators;
  hostname = "proteus-sp4";
  specialArgs = inputs // {inherit mylib myvars;};
  nixpkgs_modules = map mylib.relative_to_root [
    "modules/secrets"
    "overlays"
    "modules/nixos/common"
    "modules/nixos/desktop"
    "modules/nixpaks"
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
            # TODO
            # hosts/idols-ai/netdev-mount.nix
          ];
          system.stateVersion = "25.05";
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
