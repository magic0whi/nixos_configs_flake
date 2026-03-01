{inputs}: let
  inherit (inputs.nixpkgs) lib;
in {
  ## System agnostic functions
  # Use path relative to the root of the project
  relative_to_root = lib.path.append ../.;

  scan_path = p: map (fn: p + "/${fn}") (builtins.attrNames (
    lib.filterAttrs (
        e: t: !(lib.hasPrefix "_" e) # Exclude if `_` prefix
        # Include directories and *.nix, exclude default.nix
        && ((t == "directory") || ((lib.hasSuffix ".nix" e) && (e != "default.nix")))
      )
      (builtins.readDir p)
  ));
  ## System dependent functions
  mk_for_system = _system: let
    pkgs = inputs.nixpkgs.legacyPackages.${_system};
  in {
    # Create a symlink of dir/file out of /nix/store (with prefix `custom_`)
    mk_out_of_store_symlink = path: let
      path_str = builtins.toString path;
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

    # Args to generate nixosSystem/darwinSystem
    gen_system_args = {
      name,
      mylib,
      myvars,
      nixpkgs_modules,
      hm_modules,
      machine_path,
      enable_persistence ? true,
      system ? _system
    }: let
      inherit (inputs)
        home-manager
        impermanence
        lanzaboote
        agenix
        sops-nix
        catppuccin
        disko
        i915-sriov-dkms;
      specialArgs = inputs // {inherit mylib myvars;};
    in {
      inherit system specialArgs;
      modules = (if enable_persistence then
        nixpkgs_modules
      else
        builtins.filter (p: # Filter out the files with `impermanence.nix`
          # suffix
          # If it is not a path or string (i.e. an attribute set), return true
          # immediately to keep it
          !(builtins.isPath p || builtins.isString p)
          || !lib.strings.hasSuffix "impermanence.nix" p)
          nixpkgs_modules
      )
      ++ (if pkgs.stdenv.isDarwin then [
          agenix.darwinModules.age
          sops-nix.nixosModules.sops
        ] else [
          agenix.nixosModules.age
          sops-nix.nixosModules.sops
          lanzaboote.nixosModules.lanzaboote
          catppuccin.nixosModules.catppuccin
          disko.nixosModules.disko
          i915-sriov-dkms.nixosModules.default
        ]
        ++ (lib.optional enable_persistence impermanence.nixosModules.impermanence)
      )
      ++ [{
        imports = let
          all_machine_files = mylib.scan_path machine_path;
        in if enable_persistence then
          all_machine_files
        else
          builtins.filter
            (p: !lib.strings.hasSuffix "impermanence.nix" p)
            all_machine_files;
        networking.hostName = name;
      }]
      ++ (lib.optionals ((lib.lists.length hm_modules) > 0) [
        home-manager.${if pkgs.stdenv.isDarwin then "darwinModules" else "nixosModules"}.home-manager {
          home-manager.backupFileExtension = "home-manager.backup";
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."${myvars.username}".imports = hm_modules
          ++ [catppuccin.homeModules.catppuccin]
          ++ [(machine_path + "/_hm")];
        }
      ]);
    };
  };
}
