{
  description = "Proteus Qian's nix configuration for NixOS & WSL";
  inputs = {
    # Pinned as of 2026-3-1 12:21, branch: nixos-unstable
    nixpkgs.url = "github:NixOS/nixpkgs/dd9b079222d43e1943b6ebd802f04fd959dc8e61";
    home-manager = { # Pinned as of 2026-3-1 12:39
      url = "github:nix-community/home-manager/58fd7ff0eec2cda43e705c4c0585729ec471d400";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the
      # `inputs.nixpkgs` of the current flake, to avoid problems caused by
      # different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = { # Pinned as of 2026-3-1 12:37
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "deploy-rs/flake-compat";
      inputs.rust-overlay.url = "github:oxalica/rust-overlay/stable";
    };
    # Pinned as of 2026-3-1 12:36
    impermanence = {
      url = "github:nix-community/impermanence/7b1d382faf603b6d264f58627330f9faa5cba149";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixpak = { # Pinned as of 2026-3-1 12:38
      url = "github:nixpak/nixpak/4276954ad4f877d79801fd8952af38a3370bcb65";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = { # Pinned as of 2026-3-1 12:36
      url = "github:ryantm/agenix/b027ee29d959fda4b60b57566d64c98a202e0feb";
      # url = "github:ryantm/agenix/fcdea223397448d35d9b31f798479227e80183f6";
      # replaced with a type-safe reimplementation to get a better error message and less bugs.
      # url = "github:ryan4yin/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    pgp2ssh = { # Pinned as of 2026-3-1 12:40
      url = "github:pinpox/pgp2ssh/792e3a3f107e6b4da7b96ded5d46b69efc45d8c1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = { # Pinned as of 2026-3-1 12:40
      url = "github:Mic92/sops-nix/dec4d8eac700dcd2fe3c020857d3ee220ec147f1";
      inputs.nixpkgs.follows = "nixpkgs";};
    deploy-rs = { # Pinned as of 2026-3-1 11:16
      url = "github:serokell/deploy-rs/77c906c0ba56aabdbc72041bf9111b565cdd6171";
      # TODO: test if apple_sdk stubs still occur
      # https://github.com/serokell/deploy-rs/issues/322
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = { # Pinned as of 2026-3-1 12:42
      url = "github:nix-darwin/nix-darwin/3bfa436c1975674ca465ce34586467be301ff509";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = { # Pinned as of 2026-3-1 12:44
      url = "github:catppuccin/nix/v25.11"; # It's a tag
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = { # Pinned as of 2026-3-1 12:45
      url = "github:nix-community/disko/v1.13.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Pinned as of 2026-3-1 12:46
    nixos-hardware.url = "github:NixOS/nixos-hardware/41c6b421bdc301b2624486e11905c9af7b8ec68e";
    i915-sriov-dkms = { # As of 2026-3-1 12:47
      url = "github:strongtz/i915-sriov-dkms/2026.02.09";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs: import ./main.nix inputs;
}
