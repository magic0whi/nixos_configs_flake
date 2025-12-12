{agenix, config, ...}: {
  imports = [agenix.homeManagerModules.default];
  age.identityPaths = ["${config.home.homeDirectory}/sync_work/3keys/pgp2ssh.priv.key"];
}
