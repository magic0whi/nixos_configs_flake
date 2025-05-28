{lib, mylib, system, ...}@args: let
  machines = map (i: import i args) (mylib.scan_path ./${system});
in {
  debug_attrs = {inherit machines;}; # TIP: Use 'builtins.elemAt lists index' to keep lazy eval
  # Merge all the same arch machines into a single attribute set
  nixos_configurations = lib.mergeAttrsList (map (i: i.nixos_configurations or {}) machines);
  darwin_configurations = lib.mergeAttrsList (map (i: i.darwin_configurations or {}) machines);
  packages = lib.attrsets.mergeAttrsList (map (i: i.packages or {}) machines);
  colmena = {
    meta = {
      nodeNixpkgs = lib.attrsets.mergeAttrsList (map
        (i: i.colmena_meta.node_nixpkgs or {})
        machines
      );
      nodeSpecialArgs = lib.attrsets.mergeAttrsList (map
        (i: i.colmena_meta.node_specialArgs or {})
        machines
      );
    };
  } // lib.attrsets.mergeAttrsList (map (i: i.colmena or {}) machines);
}
