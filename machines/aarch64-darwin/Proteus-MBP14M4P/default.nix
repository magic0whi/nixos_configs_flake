{inputs, mylib, myvars, ...}: let
  name = baseNameOf ./.;
  nixpkgs_modules = map mylib.relative_to_root [
    "modules/secrets/darwin.nix"
    "modules/overlays/catppuccin.nix"
    "modules/darwin"
  ];
  hm_modules = map mylib.relative_to_root ["modules/hm-darwin"];
  darwin_system = inputs.nix-darwin.lib.darwinSystem (mylib.gen_system_args {
    inherit name mylib myvars nixpkgs_modules hm_modules;
    machine_path = ./.;
  });
in {
  _DEBUG = {inherit name nixpkgs_modules hm_modules;};
  darwin_configurations.${name} = darwin_system;
  # It’s only possible to cross compile between aarch64-darwin and x86_64-darwin
  # Ref: https://nix.dev/tutorials/cross-compilation.html#determining-the-host-platform-config
  # deploy-rs_node.${name} = {
  #   hostname = "${name}.tailba6c3f.ts.net";
  #   profiles.system = {
  #     path = inputs.deploy-rs.lib.${system}.activate.darwin darwin_system;
  #     user = "root";
  #   };
  # };
}
