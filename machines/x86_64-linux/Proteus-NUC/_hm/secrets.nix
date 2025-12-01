{agenix, myvars, ...}: {
  imports = [agenix.homeManagerModules.default];
  age.identityPaths = ["/srv/sync_work/3keys/pgp2ssh.priv.key"];
  age.secrets = {
    "syncthing_proteus-nuc.priv.pem" = {
      file = "${myvars.secrets_dir}/syncthing_proteus-nuc.priv.pem.age";
      mode = "0500";
    };
  };
}
