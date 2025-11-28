{agenix, mylib, ...}: {
  imports = [agenix.homeManagerModules.default];
  age.identityPaths = ["/srv/sync_work/3keys/pgp2ssh.priv.key"];
  age.secrets = let
    high_security = {mode = "0500";};
  in {
    "syncthing_proteus-nuc.priv.pem" = {
      file = "${mylib.relative_to_root "custom_files"}/syncthing_proteus-nuc.priv.pem.age";
    } // high_security;
  };
}
