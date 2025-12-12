{inputs, mylib, myvars, system, ...}: let
  name = baseNameOf ./.;
  nixpkgs_modules = map mylib.relative_to_root [
    "modules/secrets/common.nix"
    "modules/overlays"
    "modules/common"
    "modules/nixos_headless"
    "modules/nixos_headless/_impermanence.nix"
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
  nixos_iso = inputs.nixos-generators.nixosGenerate ((mylib.gen_system_args {
    inherit name mylib myvars nixpkgs_modules hm_modules;
    enable_persistence = false;
    machine_path = ./.;
  }) // {format = "iso";});
in {
  _DEBUG = {inherit name nixpkgs_modules hm_modules myvars mylib;};
  nixos_configurations.${name} = nixos_system;
  # generate iso image
  # packages.${name} = inputs.self.nixosConfigurations.${name}.config.formats.iso;
  packages.${name} = nixos_iso;
  deploy-rs_node.${name} = {
    hostname = "${name}";
    profiles.system = {
      path = inputs.deploy-rs.lib.${system}.activate.nixos nixos_system;
      user = "root";
    };
  };
}
