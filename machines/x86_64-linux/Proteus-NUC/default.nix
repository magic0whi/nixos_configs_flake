{inputs, mylib, myvars, system, ...}: let
  name = baseNameOf ./.;
  nixpkgs_modules = map mylib.relative_to_root [
    "modules/secrets/common.nix"
    "modules/overlays"
    "modules/common"
    "modules/nixos_headless"
    "modules/nixos_gui"
  ];
  hm_modules = map mylib.relative_to_root [
    "modules/common_hm_headless"
    "modules/common_hm_gui"
    "modules/nixos_hm_headless"
    "modules/nixos_hm_gui"
  ];
  nixos_system = inputs.nixpkgs.lib.nixosSystem (mylib.gen_system_args {
    inherit name mylib myvars nixpkgs_modules hm_modules;
    machine_path = ./.;
  });
in {
  _DEBUG = {inherit name nixpkgs_modules hm_modules myvars;};
  nixos_configurations.${name} = nixos_system;
  # generate iso image
  packages.${name} = inputs.self.nixosConfigurations.${name}.config.formats.iso;
  deploy-rs_node.${name} = {
    hostname = "${name}.tailba6c3f.ts.net";
    profiles.system = {
      path = inputs.deploy-rs.lib.${system}.activate.nixos nixos_system;
      user = "root";
    };
  };
}
