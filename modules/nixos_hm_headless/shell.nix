{config, lib, ...}: {
  home.sessionVariables.BROWSER = lib.mkDefault "google-chrome-stable"; # Set default applications
  home.shellAliases = {
    ip = lib.mkDefault "ip --color=auto";
    Ci = lib.mkDefault "wl-copy";
    Co = lib.mkDefault "wl-paste";
    Coimg = lib.mkDefault "Co --type image";
  };
  programs.bash = { # TODO: move to zsh
    enable = lib.mkDefault true;
    enableCompletion = lib.mkDefault true;
    bashrcExtra = let
      local_bin = "${config.home.homeDirectory}/.local/bin";
      go_bin = "${config.home.homeDirectory}/go/bin";
      rust_bin = "${config.home.homeDirectory}/.cargo/bin";
    in ''export PATH="$PATH:${local_bin}:${go_bin}:${rust_bin}"'';
  };
}
