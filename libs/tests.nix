{pkgs, inputs}: let
  inherit (pkgs) lib;
  mylib = import ./default.nix {inherit inputs;};
  mylib_sys = mylib.mk_for_system pkgs.stdenv.hostPlatform.system;
in lib.runTests {
  ## START System Agnostic Tests
  testrelative_to_root = {expr = mylib.relative_to_root "test_dir"; expected = ../. + "/test_dir";};
  ## END System Agnostic Tests
  ## START System Dependent Tests
  # Verifies that mk_out_of_store_symlink correctly strips unsafe characters
  # from the generated derivation name.
  test_mk_out_of_store_symlink_symlink_name_sanitization = {
    expr = (mylib_sys.mk_out_of_store_symlink "/home/user/my unsafe path!@#.txt").name;
    expected = "custom_myunsafepath.txt";
  };
  # Verifies that when generate_iso = true, impermanence.nix files are
  # correctly filtered out of the nixpkgs_modules array.
  test_gen_system_args_impermanence_filtered = {
    expr = let
      args = mylib_sys.gen_system_args {
        inherit mylib;
        name = "test-host";
        myvars = {username = "testuser";};
        nixpkgs_modules = ["bar_impermanence.nix" "impermanence.nix"];
        hm_modules = [];
        machine_path = ./.; # Using current dir just so readDir doesn't crash
        generate_iso = true;
      };
    in (builtins.elem "bar_impermanence.nix" args.modules
        || builtins.elem "impermanence.nix" args.modules);
    expected = false;
  };
  # Verifies that when generate_iso = false, impermanence.nix files are
  # kept in the module array.
  test_gen_system_args_impermanence_kept = {
    expr = let
      args = mylib_sys.gen_system_args {
        inherit mylib;
        name = "test-host";
        myvars = {username = "testuser";};
        nixpkgs_modules = ["foo_impermanence.nix" "impermanence.nix"];
        hm_modules = [];
        machine_path = ./.;
        generate_iso = false;
      };
    in (builtins.elem "foo_impermanence.nix" args.modules
        && builtins.elem "impermanence.nix" args.modules);
    expected = true;
  };
  ## END System Dependent Tests
}
