{config, ...}: {
  age.identityPaths = ["${config.home.homeDirectory}/Secrets/pgp2ssh.priv.key"];
  sops.gnupg.home = config.programs.gpg.homedir;
}
