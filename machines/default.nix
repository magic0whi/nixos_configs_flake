{lib, mylib, system, ...}@args: let
  machines = map (i: import i args) (mylib.scan_path ./${system});
in {
  _DEBUG = {inherit machines;}; # TIP: Use 'builtins.elemAt lists index' to keep lazy eval
  # Merge all the same arch machines into a single attribute set
  nixos_configurations = lib.attrsets.mergeAttrsList (map (i: i.nixos_configurations or {}) machines);
  darwin_configurations = lib.attrsets.mergeAttrsList (map (i: i.darwin_configurations or {}) machines);
  packages = lib.attrsets.mergeAttrsList (map (i: i.packages or {}) machines);
  deploy-rs_nodes = lib.attrsets.mergeAttrsList (map (i: i.deploy-rs_node or {}) machines);
}
