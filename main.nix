{self, ...}@inputs: let
  inherit (inputs.nixpkgs) lib;
  args_fn = let # The args given to other nix files
    mylib_fn = system: import ./libs {inherit inputs system;};
    myvars = import ./vars {inherit lib;};
  in system: {inherit inputs lib system myvars; mylib = mylib_fn system;};
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
  _DEBUG = {inherit inputs args_fn nixos_systems darwin_systems;};
  # Merge all the machines into a single attribute set (Multi-arch)
  nixosConfigurations = lib.attrsets.mergeAttrsList (map (i: i.nixos_configurations or {}) nixos_systems_values);
  packages = lib.genAttrs # Packages: iso
    (builtins.attrNames nixos_systems)
    (system: nixos_systems.${system}.packages or {});
  darwinConfigurations = lib.attrsets.mergeAttrsList (map (i: i.darwin_configurations or {}) darwin_systems_values);
  deploy = {
    interactiveSudo = true;
    fastConnection = true;
    nodes = lib.attrsets.mergeAttrsList (map (i: i.deploy-rs_nodes or {}) nixos_systems_values);
  };
  checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
}
