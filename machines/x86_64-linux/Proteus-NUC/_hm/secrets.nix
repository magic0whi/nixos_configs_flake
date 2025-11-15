{agenix, myvars, mylib, ...}: {
  imports = [agenix.homeManagerModules.default];
  age.identityPaths = ["/home/${myvars.username}/sync_work/3keys/private/legacy/proteus_ed25519.key"];
  age.secrets = let
    noaccess = {mode = "0000";};
    high_security = {mode = "0500";};
  in {
    "syncthing_proteus-nuc.key.pem" = {file = "${mylib.relative_to_root "custom_files"}/syncthing_proteus-nuc.key.pem.age";} // high_security;
  };
}
