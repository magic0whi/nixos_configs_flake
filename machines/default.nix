{lib, mylib, ...}@args: let
  hosts = map (i: import i args) (mylib.scan_path ./${args.system}/hosts);
in {
  # Merge all the machine's data into a single attribute set.
  nixos_configurations = lib.mergeAttrsList (
    map (i: i.nixos_configurations or {}) hosts
  );
  packages = lib.attrsets.mergeAttrsList (map (i: i.packages or {}) hosts);
}
