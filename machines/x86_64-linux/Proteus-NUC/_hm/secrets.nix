{config, ...}: {
  age.identityPaths = ["${config.home.homeDirectory}/Secrets/pgp2ssh.priv.key"];
  # TODO use original PGP key
  sops.age = {
    sshKeyPaths = [
      "${config.home.homeDirectory}/Secrets/Backup/proteus@agenix-recovery.ssh.priv.key"
      # "${config.home.homeDirectory}/Secrets/pgp2ssh.priv.key"
    ];
    keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    generateKey = true;
  };
}
