{...}@inputs: let
  inherit (inputs.nixpkgs) lib;
  mylib_fn = system: import ./libs {inherit inputs system;};
  myvars_fn = system: import ./vars {inherit (inputs) nixpkgs; inherit system;};
  # The args given to other nix files
  args_fn = system: {inherit inputs lib system; mylib = mylib_fn system; myvars = myvars_fn system;};
  nixos_systems = {
    x86_64-linux = import ./machines (args_fn "x86_64-linux");
    # aarch64-linux = import ../machines/aarch64-linux (args // {system = "aarch64-linux";});
    # riscv64-linux = import ../machines/riscv64-linux (args // {system = "riscv64-linux";});
  };
  darwin_systems.aarch64-darwin = import ./machines (args_fn "aarch64-darwin");
  nixos_systems_values = builtins.attrValues nixos_systems;
  darwin_systems_values = builtins.attrValues darwin_systems;
in {
  # Add attribute sets into outputs for debugging
  debug_attrs = {inherit args_fn mylib_fn nixos_systems darwin_systems_values;};
  # Merge all the machines into a single attribute set (Multi-arch)
  nixosConfigurations = lib.mergeAttrsList (map (i: i.nixos_configurations or {}) nixos_systems_values);
  packages = lib.genAttrs # Packages: iso
    (builtins.attrNames nixos_systems)
    (system: nixos_systems.${system}.packages or {});
  darwinConfigurations = lib.mergeAttrsList (map (i: i.darwin_configurations or {}) darwin_systems_values);
  colmenaHive = inputs.colmena.lib.makeHive (lib.recursiveUpdate
    {meta.nixpkgs = import inputs.nixpkgs {system = "x86_64-linux";};} # meta.nixpkgs is required
    (lib.mergeAttrsList (map (i: i.colmena or {}) nixos_systems_values))
  );
}
