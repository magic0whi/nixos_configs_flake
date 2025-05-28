{inputs, mylib, myvars, system, ...}: let
  name = baseNameOf ./.;
  darwin_modules = map mylib.relative_to_root [
    "modules/secrets"
    "modules/darwin"
  ];
  hm_modules = map mylib.relative_to_root [
  ];
  darwin_system_args = mylib.gen_darwin_system_args {
    inherit name mylib myvars darwin_modules hm_modules;
    machine_path = ./.;
  };
in {
  debug_attrs = {inherit name darwin_modules hm_modules darwin_system_args;};
  darwin_configurations.${name} = inputs.nix-darwin.lib.darwinSystem darwin_system_args;
  colmena.${name} = mylib.colmena_system {
    inherit (darwin_system_args) modules;
    tags = ["macos-laptop"];
  };
  colmena_meta = {
    node_nixpkgs = {${name} = import inputs.nixpkgs {inherit system;};};
    node_specialArgs = {${name} = darwin_system_args.specialArgs;};
  };
}
