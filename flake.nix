{
  description = "Proteus Qian's nix configuration for NixOS & WSL";
  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/b39a9d979c20a4242ee725bebdff7b773638ad21";
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
    wallpapers = {
      url = "github:ryan4yin/wallpapers";
      flake = false;
    };
    # secrets management
    agenix = {
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util = { # Fix .app programs installed by Nix on Mac not verified
      url = "github:hraban/mac-app-util";
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
