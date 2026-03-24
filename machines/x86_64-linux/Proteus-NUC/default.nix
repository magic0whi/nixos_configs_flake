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
    inherit name mylib nixpkgs_modules hm_modules;
    myvars = myvars // {
      igpu_sym_name = "intel";
      igpu_pci_ids = "0000:00:02.0"; # `lspci -Dnnd 8086::03xx | cut -f1 -d' '`
      dgpu_sym_name = "nvidia";
      dgpu_pci_ids = "0000:01:00.0"; # `lspci -Dnnd 10de::03xx | cut -f1 -d' '`
    };
    machine_path = ./.;
  });
  nixos_iso = (inputs.nixpkgs.lib.nixosSystem (mylib.gen_system_args {
    inherit name mylib myvars nixpkgs_modules hm_modules;
    generate_iso = true;
    machine_path = ./.;
  })).config.system.build.images.iso;
in {
  _DEBUG = {inherit name nixpkgs_modules hm_modules myvars mylib;};
  nixos_configurations.${name} = nixos_system;
  # generate iso image
  # packages.${name} = inputs.self.nixosConfigurations.${name}.config.formats.iso;
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
