{self, nixpkgs, deploy-rs, git-hooks, ...}@inputs: let
  inherit (inputs.nixpkgs) lib;
  # Functions
  for_each_system = lib.genAttrs (builtins.attrNames (nixos_systems // darwin_systems));
  args_fn = let # The args given to other nix files
    mylib = import ./libs {inherit inputs;};
    myvars = import ./vars {inherit lib mylib;};
  in system: {inherit inputs lib system myvars; mylib = mylib // (mylib.mk_for_system system);};
  # Variables
  import_each_system = supported_systems: lib.genAttrs supported_systems (system: import ./machines (args_fn system));
  nixos_systems = let supported_nixos_systems = [
    "x86_64-linux"
    # "aarch64-linux"
    # "riscv64-linux" # Disable temporary, TODO: Remove closures that has GHC dependency
  ]; in import_each_system supported_nixos_systems;
  darwin_systems = let supported_darwin_systems = [
    # "x86_64-darwin"
    "aarch64-darwin"
  ]; in import_each_system supported_darwin_systems;
  nixos_systems_values = builtins.attrValues nixos_systems;
  darwin_systems_values = builtins.attrValues darwin_systems;
in {
  # Add attribute sets into outputs for debugging
  _DEBUG = {inherit inputs args_fn nixos_systems darwin_systems;};
  # Merge all the machines into a single attribute set (Multi-arch)
  nixosConfigurations = lib.attrsets.mergeAttrsList (map (i: i.nixos_configurations or {}) nixos_systems_values);
  packages = lib.genAttrs # Packages: iso
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
    lib_checks = lib.genAttrs (builtins.attrNames (nixos_systems // darwin_systems)) (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      test_results = import ./libs/tests.nix {inherit pkgs inputs;};
    in {
      mylib_tests = if test_results == [] then
        pkgs.runCommand "lib-tests-passed" {} ''
          echo "All custom library unit tests passed on ${system}!"
          touch $out
        ''
      else
        builtins.throw ''
          Library unit tests failed on ${system}!
          ${builtins.toJSON test_results}
        '';
      pre-commit-check = git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          # nixfmt-rfc-style is now the same as pkgs.nixfmt which should be used instead.
          nixfmt = {enable = false; settings.width = 120;};
          alejandra.enable = true;
        };
      };
    });
  in lib.recursiveUpdate deploy_checks lib_checks;
  # Run pre-commit hooks with `nix fmt`
  formatter = for_each_system (system: let
    pkgs = nixpkgs.legacyPackages.${system};
    config = self.checks.${system}.pre-commit-check.config;
    inherit (config) package configFile;
    script = "${pkgs.lib.getExe package} run --all-files --config ${configFile}";
  in
    pkgs.writeShellScriptBin "pre-commit-run" script
  );

  # Enter shell run pre-commit manually with `nix develop -c pre-commit run --all-files`
  devShells = for_each_system (system: {default = let
    inherit (self.checks.${system}.pre-commit-check) shellHook enabledPackages;
    pkgs = nixpkgs.legacyPackages.${system};
  in
    pkgs.mkShell {inherit shellHook; buildInputs = enabledPackages;};
  });
}
