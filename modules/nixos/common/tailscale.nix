{config, pkgs, ...}:
# Tailscale stores its data in /var/lib/tailscale, which is already persistent across reboots(via impermanence.nix)
# References:
# https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/networking/tailscale.nix
{
  environment.systemPackages = [pkgs.tailscale];
  services.tailscale = {
    enable = true; # enable the tailscale service
    # allow the Tailscale UDP port through the firewall
    openFirewall = true;
    useRoutingFeatures = "client"; # "server" if act as exit node
    # extraUpFlags = "--accept-routes";
    # authKeyFile = "/var/lib/tailscale/authkey";
  };
}
