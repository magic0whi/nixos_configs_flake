{inputs, mylib, myvars, system, ...}: let
  name = baseNameOf ./.;
  nixpkgs_modules = map mylib.relative_to_root [
    "modules/secrets/darwin.nix"
    "modules/darwin"
  ];
  hm_modules = map mylib.relative_to_root ["modules/hm-darwin"];
  darwin_system_args = mylib.gen_system_args {
    inherit name mylib myvars nixpkgs_modules hm_modules;
    machine_path = ./.;
  };
in {
  debug_attrs = {inherit name nixpkgs_modules hm_modules darwin_system_args;};
  darwin_configurations.${name} = inputs.nix-darwin.lib.darwinSystem darwin_system_args;
  colmena.${name} = mylib.colmena_system {
    inherit (darwin_system_args) modules;
    tags = ["macos-laptop"];
  };
  colmena_meta = {
    node_nixpkgs.${name} = inputs.nixpkgs.legacyPackages.${system};
    node_specialArgs.${name} = darwin_system_args.specialArgs;
  };
}
