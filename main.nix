{self, ...}@inputs: let
  inherit (inputs.nixpkgs) lib;
  args_fn = let # The args given to other nix files
    mylib = import ./libs {inherit inputs;};
    myvars = import ./vars {inherit lib mylib;};
  in system: {inherit inputs lib system myvars; mylib = mylib // (mylib.mk_for_system system);};
  import_each_system = supported_systems: lib.genAttrs supported_systems (system: import ./machines (args_fn system));
  nixos_systems = let supported_nixos_systems = [
    "x86_64-linux"
    # "aarch64-linux"
    # "riscv64-linux" # Disable temporary, TODO: Remove closures that has GHC dependency
  ]; in import_each_system supported_nixos_systems;
  darwin_systems = let supported_darwin_systems = [
    # "x86_64-darwin"
    "aarch64-darwin"
  ]; in import_each_system supported_darwin_systems;
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
