{inputs, mylib, myvars, system, ...}: let
  name = baseNameOf ./.;
  nixpkgs_modules = map mylib.relative_to_root [
    "modules/secrets/linux.nix"
    "overlays"
    "modules/nixos/common"
    "modules/nixos/desktop"
  ];
  hm_modules = map mylib.relative_to_root [
    "modules/hm/common"
    "modules/hm/desktop"
  ];
  nixos_system_args = mylib.gen_system_args {
    inherit name mylib myvars nixpkgs_modules hm_modules;
    machine_path = ./.;
  };
in {
  debug_attrs = {inherit name nixpkgs_modules hm_modules nixos_system_args;};
  nixos_configurations.${name} = inputs.nixpkgs.lib.nixosSystem nixos_system_args;
  # generate iso image
  packages.${name} = inputs.self.nixosConfigurations.${name}.config.formats.iso;
  colmena.${name} = mylib.colmena_system {
    inherit (nixos_system_args) modules;
    tags = ["main-laptop"];
  };
  colmena_meta = {
    node_nixpkgs.${name} = inputs.nixpkgs.legacyPackages.${system};
    node_specialArgs.${name} = nixos_system_args.specialArgs;
  };
}
