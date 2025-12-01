{inputs, mylib, myvars, system, ...}: let
  name = baseNameOf ./.;
  nixpkgs_modules = map mylib.relative_to_root [
    "modules/secrets/common.nix"
    "modules/common"
    "modules/nixos_headless/impermanence.nix"
    "modules/nixos_headless/stew.nix"
    "modules/nixos_headless/packages.nix"
    "modules/nixos_headless/sing-box.nix"
  ];
  hm_modules = map mylib.relative_to_root [
    "modules/common_hm_headless/git.nix"
    "modules/common_hm_headless/helix.nix"
    "modules/common_hm_headless/shell.nix"
    "modules/common_hm_headless/stew.nix"
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
    hostname = "192.168.64.4";
    profiles.system = {
      path = inputs.deploy-rs.lib.${system}.activate.nixos nixos_system;
      user = "root";
    };
  };
}
