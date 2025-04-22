{lib, ...}: {
  relative_to_root = lib.path.append ../.;  # use path relative to the root of the project
  scan_path = p: map (fn: p + "/${fn}") (builtins.attrNames
    (lib.filterAttrs (e: t: (t == "directory") || ((e != "default.nix") && (lib.hasSuffix ".nix" e)) # include directories, ignore default.nix, include .nix files
    ) (builtins.readDir p))
  );
}
