{agenix, ...}: {
  imports = [agenix.homeManagerModules.default];
  age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];
}
