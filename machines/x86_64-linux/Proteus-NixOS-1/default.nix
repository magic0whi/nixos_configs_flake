{inputs, mylib, myvars, system, ...}: let
  name = baseNameOf ./.;
  nixpkgs_modules = map mylib.relative_to_root [
    "modules/secrets/linux.nix"
    "modules/overlays/catppuccin.nix"
    "modules/common"
    "modules/nixos_headless"
  ];
  hm_modules = map mylib.relative_to_root [
    "modules/common_hm_headless"
    "modules/nixos_hm_headless"
  ];
  nixos_system = inputs.nixpkgs.lib.nixosSystem (mylib.gen_system_args {
    inherit name mylib myvars nixpkgs_modules hm_modules;
    machine_path = ./.;
  });
in {
  _DEBUG = {inherit name nixpkgs_modules hm_modules;};
  nixos_configurations.${name} = nixos_system;
  # generate iso image
  packages.${name} = inputs.self.nixosConfigurations.${name}.config.formats.iso;
  deploy-rs_node.${name} = {
    hostname = "79.76.120.128";
    profiles.system = {
      path = inputs.deploy-rs.lib.${system}.activate.nixos nixos_system;
      user = "root";
    };
  };
}
