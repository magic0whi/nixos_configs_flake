{config, agenix, pkgs, myvars, ...}: {
  # For debugging
  environment.systemPackages = [
    agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.sops
  ];

  age.identityPaths = if (config.environment ? persistence && config.environment.persistence != {}) then [
    "/persistent${config.users.users.${myvars.username}.home}/Secrets/pgp2ssh.priv.key"
    "/persistent/etc/ssh/ssh_host_ed25519_key"
  ] else [
    "${config.users.users.${myvars.username}.home}/Secrets/pgp2ssh.priv.key" "/etc/ssh/ssh_host_ed25519_key"
  ];

  sops.defaultSopsFile = "${myvars.secrets_dir}/secrets.yaml";
  sops.age.sshKeyPaths = if (config.environment ? persistence && config.environment.persistence != {}) then [
    "/persistent/etc/ssh/ssh_host_ed25519_key"
  ] else [
    "/etc/ssh/ssh_host_ed25519_key"
  ];
}
