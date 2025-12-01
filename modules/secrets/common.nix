{config, agenix, pkgs, myvars, ...}: {
  environment.systemPackages = [agenix.packages.${pkgs.stdenv.hostPlatform.system}.default]; # For debugging
  age.identityPaths = if (config.environment ? persistence && config.environment.persistence != {}) then [
    "/persistent${config.users.users.${myvars.username}.home}/sync_work/3keys/pgp2ssh.priv.key"
    "/persistent/etc/ssh/ssh_host_ed25519_key"
  ] else [
    "${config.users.users.${myvars.username}.home}/sync_work/3keys/pgp2ssh.priv.key"
    "/etc/ssh/ssh_host_ed25519_key"
  ];
}
