{
  description = "Proteus Qian's nix configuration for NixOS & WSL";
  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/1412caf7bf9e660f2f962917c14b1ea1c3bc695e"; # nixos-unstable as of 1/15/26 12:53
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the
      # `inputs.nixpkgs` of the current flake, to avoid problems caused by
      # different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "deploy-rs/flake-compat";
      inputs.rust-overlay.url = "github:oxalica/rust-overlay/stable";
    };
    impermanence.url = "github:nix-community/impermanence";
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "lanzaboote/flake-parts";
    };
    # generate iso/qcow2/docker/... image from nixos configuration
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = { # secrets management
      url = "github:ryantm/agenix";
      # replaced with a type-safe reimplementation to get a better error message and less bugs.
      # url = "github:ryan4yin/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    pgp2ssh = {
      url = "github:pinpox/pgp2ssh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      # inputs.nixpkgs.follows = "nixpkgs"; # https://github.com/serokell/deploy-rs/issues/322
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    i915-sriov-dkms = {
      url = "github:strongtz/i915-sriov-dkms";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # my private secrets, it's a private repository, you need to replace it with your own. TODO
    # use ssh protocol to authenticate via ssh-agent/ssh-key, and shallow clone to save time
    # mysecrets = {
      # url = "git+ssh://git@github.com/ryan4yin/nix-secrets.git?shallow=1";
      # flake = false;
    # };
  };
  outputs = inputs: import ./main.nix inputs;
}
