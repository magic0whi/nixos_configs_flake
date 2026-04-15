{agenix, config, ...}: {
  imports = [agenix.homeManagerModules.default];
  age.identityPaths = ["${config.home.homeDirectory}/Secrets/pgp2ssh.priv.key"];
}
