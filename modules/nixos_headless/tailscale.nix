{lib, ...}:
# Tailscale stores its data in /var/lib/tailscale, which is already persistent across reboots(via impermanence.nix)
# References:
# https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/networking/tailscale.nix
{
  systemd.services.tailscaled.environment.TS_DEBUG_FIREWALL_MODE = lib.mkDefault "auto"; # Auto detect the firewall type (nftables)
  services.tailscale = {
    enable = lib.mkDefault true; # enable the tailscale service
    openFirewall = lib.mkDefault true; # allow the Tailscale UDP port through the firewall
    useRoutingFeatures = lib.mkDefault "client"; # "server" if act as exit node
    # extraUpFlags = "--accept-routes";
    # authKeyFile = "/var/lib/tailscale/authkey";
  };
}
