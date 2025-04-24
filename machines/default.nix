{lib, mylib, ...}@args: let
  machines = map (i: import i args) (mylib.scan_path ./${args.system});
in {
  # Merge all the same arch machines into a single attribute set
  nixos_configurations = lib.mergeAttrsList (
    map (i: i.nixos_configurations or {}) machines
  );
  packages = lib.attrsets.mergeAttrsList (map (i: i.packages or {}) machines);
}
