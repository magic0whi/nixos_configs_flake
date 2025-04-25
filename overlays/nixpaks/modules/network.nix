# https://github.com/nixpak/pkgs/blob/master/pkgs/modules/network.nix
{ # Current QUIC is broken
  etc.sslCertificates.enable = true;
  bubblewrap.network = true;
}
