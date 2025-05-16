{nixpkgs, system, ...}: let inherit (nixpkgs) lib; in {
  relative_to_root = lib.path.append ../.;  # use path relative to the root of the project
  scan_path = p: map (fn: p + "/${fn}") (builtins.attrNames
    (lib.filterAttrs (e: t: (t == "directory") || ((e != "default.nix") && (lib.hasSuffix ".nix" e)) # include directories, ignore default.nix, include .nix files
    ) (builtins.readDir p))
  );
  mk_out_of_store_symlink = path: let # Create a symlink of dir/file out of /nix/store
      pkgs = nixpkgs.legacyPackages.${system};
      path_str = toString path;
      store_filename = path: let # Filter unsafe chars
        safe_chars = ["+" "." "_" "?" "="] ++ lib.lowerChars ++ lib.upperChars ++ lib.strings.stringToCharacters "0123456789";
        gen_empt_lst = len: builtins.genList (e: "") (builtins.length len);
        unsafe_chars = lib.strings.stringToCharacters (builtins.replaceStrings safe_chars (gen_empt_lst safe_chars) path);
        safe_name = builtins.replaceStrings unsafe_chars (gen_empt_lst unsafe_chars) path;
      in "custom_" + safe_name;
      name = store_filename (baseNameOf path_str);
    in pkgs.runCommandLocal name {} "ln -s ${lib.escapeShellArg path_str} $out";
}
