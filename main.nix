{...}@inputs: let
  inherit (inputs.nixpkgs) lib;
  mylib = import ./libs {inherit lib;};
  myvars = import ./vars {inherit lib;};
  args = {inherit inputs lib mylib myvars;}; # The args given
  # to other nix files
  nixos_systems = {
    x86_64-linux = import ./machines (args // {system = "x86_64-linux";});
    # aarch64-linux = import ../machines/aarch64-linux (args // {system = "aarch64-linux";});
    # riscv64-linux = import ../machines/riscv64-linux (args // {system = "riscv64-linux";});
  };
  nixos_systems_values = builtins.attrValues nixos_systems;
in {
  debug_attrs = {inherit args nixos_systems;}; # Add attribute sets into outputs for debugging
  # Merge all the machines into a single attribute set (Multi-arch)
  nixosConfigurations = lib.mergeAttrsList
    (map (i: i.nixos_configurations or {}) nixos_systems_values);
  # Packages
  packages = lib.genAttrs
    (builtins.attrNames nixos_systems)
    (system: nixos_systems.${system}.packages or {});
}
