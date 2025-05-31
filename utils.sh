#!/usr/bin/env bash
# Function: darwin-build
# Args:
#   $1: name (string)
#   $2: mode (string) - e.g., "debug"
darwin-build() {
  local name="$1"
  local mode="$2"
  local target=".#darwinConfigurations.$name.system"

  if [[ "$mode" == "debug" ]]; then
      nom build "$target" --extra-experimental-features "nix-command flakes" --show-trace --verbose
  else
      nix build "$target" --extra-experimental-features "nix-command flakes"
  fi
}

# Function: darwin-switch
# Args:
#   $1: name (string)
#   $2: mode (string)
darwin-switch() {
  local name="$1"
  local mode="$2"
  local flake_path=".#$name"

  if [[ "$mode" == "debug" ]]; then
    sudo darwin-rebuild switch --flake "$flake_path" --show-trace --verbose
  else
    sudo darwin-rebuild switch --flake "$flake_path"
  fi
}

darwin-rollback() {
  darwin-rebuild --rollback
}
