{
  description = "Proteus Qian's nix configuration for NixOS & nix-darwin";
  inputs = {
    # Pinned as of 2026-04-05 17:10, branch: nixos-unstable
    nixpkgs.url = "github:NixOS/nixpkgs/6201e203d09599479a3b3450ed24fa81537ebc4e";
    nixpkgs-postgresql.url = "github:NixOS/nixpkgs/6201e203d09599479a3b3450ed24fa81537ebc4e";
    home-manager = { # Pinned as of 2026-04-05 17:27, branch: master
      url = "github:nix-community/home-manager/2097a5c82bdc099c6135eae4b111b78124604554";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the
      # `inputs.nixpkgs` of the current flake, to avoid problems caused by
      # different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = { # Pinned as of 2026-04-05 17:14
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.url = "github:oxalica/rust-overlay/stable";
    };
    # Pinned as of 2026-04-05 17:14
    impermanence = {
      url = "github:nix-community/impermanence/7b1d382faf603b6d264f58627330f9faa5cba149";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixpak = { # Pinned as of 2026-04-05 17:16
      url = "github:nixpak/nixpak/4f8cbe437ba7e047ed4582b35b8140124b9562b5";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = { # Pinned as of 2026-04-05 17:16
      url = "github:ryantm/agenix/b027ee29d959fda4b60b57566d64c98a202e0feb";
      # url = "github:ryantm/agenix/fcdea223397448d35d9b31f798479227e80183f6";
      # replaced with a type-safe reimplementation to get a better error message and less bugs.
      # url = "github:ryan4yin/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.systems.follows = "deploy-rs/utils/systems";
    };
    pgp2ssh = { # Pinned as of 2026-04-05 17:17
      url = "github:pinpox/pgp2ssh/792e3a3f107e6b4da7b96ded5d46b69efc45d8c1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = { # Pinned as of 2026-04-05 17:18
      url = "github:Mic92/sops-nix/a4ee2de76efb759fe8d4868c33dec9937897916f";
      inputs.nixpkgs.follows = "nixpkgs";};
    deploy-rs = { # Pinned as of 2026-04-05 17:18
      url = "github:serokell/deploy-rs/77c906c0ba56aabdbc72041bf9111b565cdd6171";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "lanzaboote/pre-commit/flake-compat";
    };
    nix-darwin = { # Pinned as of 2026-04-05 17:19
      url = "github:nix-darwin/nix-darwin/06648f4902343228ce2de79f291dd5a58ee12146";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = { # Pinned as of 2026-04-05 17:21, tag v25.11
      url = "github:catppuccin/nix/v25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = { # Pinned as of 2026-04-05 17:21, tag v1.13.0
      url = "github:nix-community/disko/v1.13.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Pinned as of 2026-04-05 17:22
    nixos-hardware.url = "github:NixOS/nixos-hardware/80afbd13eea0b7c4ac188de949e1711b31c2b5f0";
    i915-sriov-dkms = { # Pinned as of 2026-04-05 17:23, tag: 2026.03.05
      url = "github:strongtz/i915-sriov-dkms/2026.03.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    docspell = { # Pinned as of 2026-04-05 17:24
      url = "github:eikek/docspell/2032c3ccdfbd5651983e11764227d0923f5ea2e8";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.devshell-tools.inputs.flake-utils.follows = "deploy-rs/utils";
      inputs.devshell-tools.inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "deploy-rs/utils";
    };
  };
  outputs = inputs: import ./main.nix inputs;
}
