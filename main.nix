{...}@inputs: let
  inherit (inputs.nixpkgs) lib;
  mylib_fn = system: import ./libs {inherit inputs system;};
  myvars_fn = system: import ./vars {inherit (inputs) nixpkgs; inherit system;};
  args_fn = system: {inherit inputs lib system; mylib = mylib_fn system; myvars = myvars_fn system;}; # The args given to other nix files
  nixos_systems = {
    x86_64-linux = import ./machines (args_fn "x86_64-linux");
    # aarch64-linux = import ../machines/aarch64-linux (args // {system = "aarch64-linux";});
    # riscv64-linux = import ../machines/riscv64-linux (args // {system = "riscv64-linux";});
  };
  darwinSystems.aarch64-darwin = import ./machines (args_fn "aarch64-darwin");
  nixos_systems_values = builtins.attrValues nixos_systems;
  darwin_systems_values = builtins.attrValues darwinSystems;
in {
  debug_attrs = {inherit args_fn mylib_fn nixos_systems darwin_systems_values;}; # Add attribute sets into outputs for debugging
  # Merge all the machines into a single attribute set (Multi-arch)
  nixosConfigurations = lib.attrsets.mergeAttrsList
    (map (i: i.nixos_configurations or {}) nixos_systems_values);
  # Packages: iso
  packages = lib.genAttrs
    (builtins.attrNames nixos_systems)
    (system: nixos_systems.${system}.packages or {});
  colmenaHive = inputs.colmena.lib.makeHive (lib.recursiveUpdate
    {meta.nixpkgs = import inputs.nixpkgs {system = "x86_64-linux";};} # meta.nixpkgs is required
    (lib.attrsets.mergeAttrsList (map (i: i.colmena or {}) nixos_systems_values))
  );
  darwinConfigurations = lib.attrsets.mergeAttrsList
    (map (i: i.darwin_configurations or {}) darwin_systems_values);
}
