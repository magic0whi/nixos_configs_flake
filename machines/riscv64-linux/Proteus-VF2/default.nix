{inputs, mylib, myvars, system, ...}: let
  name = baseNameOf ./.;
  nixpkgs_modules = map mylib.relative_to_root [
    "modules/secrets/common.nix"
    "modules/common"
    "modules/nixos_headless/_impermanence.nix"
    "modules/nixos_headless/stew.nix"
    "modules/nixos_headless/packages.nix"
    "modules/nixos_headless/sing-box.nix"
    "modules/nixos_gui/kmscon.nix"
  ];
  hm_modules = map mylib.relative_to_root [
    "modules/common_hm_headless/git.nix"
    "modules/common_hm_headless/helix.nix"
    "modules/common_hm_headless/packages.nix"
    "modules/common_hm_headless/shell.nix"
    "modules/common_hm_headless/stew.nix"
    "modules/nixos_hm_headless/shell.nix"
  ];
  nixos_system = inputs.nixpkgs.lib.nixosSystem (mylib.gen_system_args {
    inherit name mylib myvars nixpkgs_modules hm_modules;
    machine_path = ./.;
  });
  nixos_sd_image = (inputs.nixpkgs.lib.nixosSystem (mylib.gen_system_args {
    inherit name mylib myvars hm_modules;
    enable_persistence = false;
    nixpkgs_modules = nixpkgs_modules ++ [{
      # imports = ["${inputs.nixos-hardware}/starfive/visionfive/v2/sd-image-installer.nix"];
      # Or
      imports = [(inputs.nixos-hardware + "/starfive/visionfive/v2/sd-image-installer.nix")];
      sdImage.compressImage = false;
      # Cross-compile
      # Or add `boot.binfmt.emulatedSystems = ["riscv64-linux"];` to your
      # NixOS configurations
      # nixpkgs.crossSystem = {
        # config = "riscv64-unknown-linux-gnu"; system = "riscv64-linux";
      # };
      disko.enableConfig = false; # nixpkgs' sd-image.nix use its built-in ext4
    }];
    machine_path = ./.;
  # }));
  })).config.system.build.sdImage;
in {
  _DEBUG = {inherit name nixpkgs_modules hm_modules myvars mylib;};
  nixos_configurations.${name} = nixos_system;
  # generate iso image
  packages.${name} = nixos_sd_image;
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
