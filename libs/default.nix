{lib, ...}: {
  relative_to_root = lib.path.append ../.;  # use path relative to the root of the project
  scan_path = p: map (fn: p + "/${fn}") (builtins.attrNames (
    lib.filterAttrs (p: _type: (_type == "directory") # include directories
      || ((p != "default.nix") && (lib.hasSuffix ".nix" p)) # ignore default.nix, include .nix files
    ) (builtins.readDir p)));
}
