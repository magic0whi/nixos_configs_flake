{inputs, mylib, myvars, system, ...}: let
  name = baseNameOf ./.;
  nixpkgs_modules = map mylib.relative_to_root [
    "modules/secrets/linux.nix"
    "overlays"
    "modules/nixos/common"
  ];
  hm_modules = map mylib.relative_to_root ["modules/hm/common"];
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
    tags = ["vps-01"];
    targetHost = "79.76.120.128";
  };
  colmena_meta = {
    node_nixpkgs.${name} = inputs.nixpkgs.legacyPackages.${system};
    node_specialArgs.${name} = nixos_system_args.specialArgs;
  };
}
