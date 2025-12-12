# Proteus-NixOS-3 London
{inputs, mylib, myvars, system, ...}: let
  name = baseNameOf ./.;
  nixpkgs_modules = map mylib.relative_to_root [
    "modules/secrets/common.nix"
    "modules/common"
    "modules/nixos_headless/_impermanence.nix"
    "modules/nixos_headless/stew.nix"
    "modules/nixos_headless/packages.nix"
    "modules/nixos_headless/sing-box.nix"
  ];
  hm_modules = map mylib.relative_to_root [
    "modules/common_hm_headless/git.nix"
    "modules/common_hm_headless/helix.nix"
    "modules/common_hm_headless/shell.nix"
    "modules/common_hm_headless/stew.nix"
    "modules/nixos_hm_headless/shell.nix"
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
  packages.${name} = nixos_iso;
  deploy-rs_node.${name} = {
    hostname = myvars.networking.hosts_addr.${name}.ipv4;
    sshUser = "root";
    interactiveSudo = false; # Since we use 'root' user to ssh
    profiles.system = {
      path = inputs.deploy-rs.lib.${system}.activate.nixos nixos_system;
      user = "root";
    };
  };
}
