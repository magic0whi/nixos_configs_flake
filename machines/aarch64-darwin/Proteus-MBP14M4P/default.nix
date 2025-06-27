{inputs, mylib, myvars, system, ...}: let
  name = baseNameOf ./.;
  nixpkgs_modules = map mylib.relative_to_root [
    "modules/secrets/darwin.nix"
    "modules/darwin"
  ];
  hm_modules = map mylib.relative_to_root ["modules/hm-darwin"];
  darwin_system_args = mylib.gen_system_args {
    inherit name mylib myvars nixpkgs_modules hm_modules;
    machine_path = ./.;
  };
in {
  debug_attrs = {inherit name nixpkgs_modules hm_modules darwin_system_args;};
  darwin_configurations.${name} = inputs.nix-darwin.lib.darwinSystem darwin_system_args;
  colmena.${name} = mylib.colmena_system {
    # inherit (darwin_system_args) modules;
    # modules = with inputs.nixpkgs.lib; darwin_system_args.modules ++ (filter (e: !((hasSuffix "system-path.nix" e) || (hasSuffix "fonts" e) || (hasSuffix "nixpkgs.nix" e) || (hasSuffix "nix" e))) (import "${inputs.nix-darwin}/modules/module-list.nix"));
    modules = darwin_system_args.modules ++ ["${inputs.nix-darwin}/modules/homebrew.nix" "${inputs.nix-darwin}/modules/launchd" "${inputs.nix-darwin}/modules/system/launchd.nix" "${inputs.nix-darwin}/modules/system/defaults/NSGlobalDomain.nix" "${inputs.nix-darwin}/modules/system/defaults/dock.nix" "${inputs.nix-darwin}/modules/system/defaults/finder.nix" "${inputs.nix-darwin}/modules/system/defaults/clock.nix" "${inputs.nix-darwin}/modules/system/defaults/trackpad.nix" "${inputs.nix-darwin}/modules/system/keyboard.nix" "${inputs.nix-darwin}/modules/system/primary-user.nix"];
    tags = ["macos-laptop"];
  };
  colmena_meta = {
    # node_nixpkgs.${name} = inputs.nixpkgs.legacyPackages.${system};
    node_nixpkgs.${name} = inputs.nixpkgs.lib.recursiveUpdate inputs.nixpkgs.legacyPackages.${system} inputs.nix-darwin.packages.${system};
    node_specialArgs.${name} = darwin_system_args.specialArgs;
  };
}
