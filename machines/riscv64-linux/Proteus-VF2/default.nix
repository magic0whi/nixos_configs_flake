{inputs, mylib, myvars, system, ...}: let
  name = baseNameOf ./.;
  nixpkgs_modules = map mylib.relative_to_root [
    # "modules/secrets/common.nix" # agenix.packages.riscv64-linux missing
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
    system = "x86_64-linux"; # Cross-compile
    machine_path = ./.;
  });
  nixos_sd_image = (inputs.nixpkgs.lib.nixosSystem (mylib.gen_system_args {
    inherit name mylib myvars hm_modules;
    enable_persistence = false;
    machine_path = ./.;
    nixpkgs_modules = nixpkgs_modules ++ [{
      # imports = ["${inputs.nixos-hardware}/starfive/visionfive/v2/sd-image-installer.nix"];
      # Or
      imports = [(inputs.nixos-hardware + "/starfive/visionfive/v2/sd-image-installer.nix")];
      sdImage.compressImage = false;
      # Cross-compile, either
      nixpkgs.buildPlatform = "x86_64-linux";
      # Or add `boot.binfmt.emulatedSystems = ["riscv64-linux"];` to your
      # NixOS configurations
      disko.enableConfig = false; # nixpkgs' sd-image.nix use its built-in ext4
      nixpkgs.overlays = [(_: prev: {
        coreutils = prev.coreutils.overrideAttrs (prev: {
          postPatch = prev.postPatch + ''
            # Fails when build through cross compile
            echo "int main() { return 77; }" > "gnulib-tests/test-free.c"
            sed '2i echo Skipping split line-bytes test && exit 77' -i ./tests/split/line-bytes.sh
          '';
        });
        findutils = prev.findutils.overrideAttrs (prev: {
          postPatch = prev.postPatch + ''
            # Fails when build through cross compile
            echo "int main() { return 77; }" > "gnulib-tests/test-free.c"
          '';
        });
        openexr = prev.openexr.overrideAttrs (_: {doCheck = false;});
        perl540Packages = prev.perl540Packages.overrideScope (_: perl_prev: {
          Test2Harness = perl_prev.Test2Harness.overrideAttrs (_: {doCheck = false;});
        });
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (_: python_prev: {
            fs = (python_prev.fs.override {pytestCheckHook = null;});
          })
        ];
        git = prev.git.overrideAttrs (prev: {
          preInstallCheck = prev.preInstallCheck + ''
            # Fails on cross-compile on riscv64-linux
            disable_test t0050-filesystem
          '';
        });
      })];
    }];
  # })); # For debug
  })).config.system.build.sdImage;
in {
  _DEBUG = {inherit name nixpkgs_modules hm_modules myvars mylib;};
  nixos_configurations.${name} = nixos_system;
  # Generate iso image
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
