{inputs, system}: let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;
  pkgs = nixpkgs.legacyPackages.${system};
in {
  relative_to_root = lib.path.append ../.;  # use path relative to the root of
  # the project
  scan_path = p: map (fn: p + "/${fn}") (builtins.attrNames
    (lib.filterAttrs ( # includedirectories (ex named hm), ignore default.nix,
      # include .nix files
      e: t: (t == "directory" && e != "hm") || ((e != "default.nix") && (lib.hasSuffix ".nix" e))
    ) (builtins.readDir p))
  );
  mk_out_of_store_symlink = path: let # Create a symlink of dir/file out of
  # /nix/store
    path_str = toString path;
    store_filename = path: let # Filter unsafe chars
      safe_chars = ["+" "." "_" "?" "="] ++ lib.lowerChars ++ lib.upperChars
      ++ lib.strings.stringToCharacters "0123456789";
      gen_empt_lst = len: builtins.genList (e: "") (builtins.length len);
      unsafe_chars = lib.strings.stringToCharacters (builtins.replaceStrings
        safe_chars (gen_empt_lst safe_chars) path);
      safe_name = builtins.replaceStrings unsafe_chars (gen_empt_lst unsafe_chars) path;
    in "custom_" + safe_name;
      name = store_filename (baseNameOf path_str);
  in pkgs.runCommandLocal name {} "ln -s ${lib.escapeShellArg path_str} $out";

  gen_system_args = {name, mylib, myvars, nixpkgs_modules, hm_modules, machine_path}: let
    inherit (inputs) home-manager nixos-generators mac-app-util;
    specialArgs = inputs // {inherit mylib myvars;};
  in {
    inherit system specialArgs;
    modules = nixpkgs_modules
    ++ (lib.optional (!pkgs.stdenv.isDarwin) nixos-generators.nixosModules.all-formats)
    ++ (lib.optional pkgs.stdenv.isDarwin mac-app-util.darwinModules.default)
    ++ [{imports = mylib.scan_path machine_path; networking.hostName = name;}]
    ++ (lib.optionals ((lib.lists.length hm_modules) > 0) [
      home-manager.${if pkgs.stdenv.isDarwin then "darwinModules" else "nixosModules"}.home-manager {
        home-manager.backupFileExtension = "home-manager.backup";
        home-manager.extraSpecialArgs = specialArgs;
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users."${myvars.username}".imports = hm_modules
        ++ (lib.optional pkgs.stdenv.isDarwin mac-app-util.homeManagerModules.default)
        ++ [(machine_path + "/hm")];
      }
    ]);
  };
  colmena_system = {
    tags ? [],
    ssh_user ? "root",
    modules,
    ...
  }: {name, ...}: { # There another arg named 'nodes' with can share configs
  # between nodes
    deployment = {
      inherit tags;
      targetUser = ssh_user;
      targetHost = name; # hostName or IP address
    };
    imports = modules;
  };
}
