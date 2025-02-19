{lib, mylib, ...}@args:
# let
  # inherit (inputs) haumea;
  # machines are haumea modules
  # data = haumea.lib.load {inputs = args; src = ./${args.system}/src;};
  # Nix file names is redundant, remove it.
  # data_values = builtins.attrValues data;
# in
{
  # Merge all the machine's data into a single attribute set.
  nixos_configurations = lib.mergeAttrsList (
    map (i: i.nixos_configurations or {})
      (map (i: import i args) (mylib.scan_path ./${args.system}/hosts)
    )
  );
}
 # outputs // {
  # debug_attrs = {inherit data;}; # For debugging purposes
  # evalTests = haumea.lib.loadEvalTests {
    # src = ./tests;
    # inputs = args // {inherit outputs;};
  # };
# }
