{
  self,
  nixpkgs,
  deploy-rs,
  treefmt-nix,
  ...
} @ inputs: let
  inherit (inputs.nixpkgs) lib;
  # Functions
  for_each_system = f:
    lib.genAttrs (builtins.attrNames (nixos_systems // darwin_systems)) (system: f nixpkgs.legacyPackages.${system});
  treefmt_eval = for_each_system (pkgs:
    treefmt-nix.lib.evalModule pkgs (_: {
      # Used to find the project root
      projectRootFile = "flake.nix";
      programs.alejandra.enable = true;
    }));
  args_fn = let
    # The args given to other nix files
    mylib = import ./libs {inherit inputs;};
    myvars = import ./vars {inherit lib mylib;};
  in
    system: {
      inherit inputs lib system myvars;
      mylib = mylib // (mylib.mk_for_system system);
    };

  # Variables
  import_each_system = supported_systems: lib.genAttrs supported_systems (system: import ./machines (args_fn system));
  nixos_systems = let
    supported_nixos_systems = [
      "x86_64-linux"
      # "aarch64-linux"
      # "riscv64-linux" # Disable temporary, TODO: Remove closures that has GHC dependency
    ];
  in
    import_each_system supported_nixos_systems;
  darwin_systems = let
    supported_darwin_systems = [
      # "x86_64-darwin"
      "aarch64-darwin"
    ];
  in
    import_each_system supported_darwin_systems;
  nixos_systems_values = builtins.attrValues nixos_systems;
  darwin_systems_values = builtins.attrValues darwin_systems;
in {
  # Add attribute sets into outputs for debugging
  _DEBUG = {inherit inputs args_fn nixos_systems darwin_systems;};
  # Merge all the machines into a single attribute set (Multi-arch)
  nixosConfigurations = lib.attrsets.mergeAttrsList (map (i: i.nixos_configurations or {}) nixos_systems_values);
  # Packages: iso images
  packages =
    lib.genAttrs
    (builtins.attrNames nixos_systems)
    (system: nixos_systems.${system}.packages or {});
  darwinConfigurations = lib.attrsets.mergeAttrsList (map (i: i.darwin_configurations or {}) darwin_systems_values);
  deploy = {
    interactiveSudo = true;
    fastConnection = true;
    nodes = lib.attrsets.mergeAttrsList (map (i: i.deploy-rs_nodes or {}) nixos_systems_values);
  };
  # Currently deploy_checks broken on MacOS
  checks = let
    deploy_checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    my_checks = for_each_system (pkgs: let
      test_results = import ./libs/tests.nix {inherit pkgs inputs;};
    in {
      mylib_tests =
        if test_results == []
        then
          pkgs.runCommand "lib-tests-passed" {} ''
            echo "All custom library unit tests passed on ${pkgs.stdenv.hostPlatform.system}!"
            touch $out
          ''
        else
          builtins.throw ''
            Library unit tests failed on ${pkgs.stdenv.hostPlatform.system}!
            ${builtins.toJSON test_results}
          '';

      format_check = treefmt_eval.${pkgs.stdenv.hostPlatform.system}.config.build.check self;
    });
  in
    lib.recursiveUpdate deploy_checks my_checks;

  formatter = for_each_system (pkgs: treefmt_eval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper);
}
