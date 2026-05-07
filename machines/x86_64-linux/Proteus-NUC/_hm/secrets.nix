{config, ...}: {
  sops.gnupg.home = config.programs.gpg.homedir;
  # sops.age = {
  #   sshKeyPaths = ["${config.home.homeDirectory}/Secrets/Backup/proteus@agenix-recovery.ssh.priv.key"];
  #   keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  #   generateKey = true;
  # };
}
