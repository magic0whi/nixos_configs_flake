{pkgs, deploy-rs, pgp2ssh, ...}: {
  programs.yt-dlp.enable = if pkgs.stdenv.hostPlatform.isRiscV64 then false else true;
  home.packages = with pkgs; [
    keepassxc # Offline password manager, provides both CLI and GUI
    just # A command runner like make, but simpler

    xmrig # Benchmark
    # Misc
    # cowsay
    # gnumake

    # yq-go # yaml processor https://github.com/mikefarah/yq

    # caddy # A webserver with automatic HTTPS via Let's Encrypt (replacement of nginx)
    # croc # File transfer between computers securely and easily
    # wireguard-tools # manage wireguard vpn manually, via wg-quick
    # ventoy # create bootable usb

    # Dev-tools
    # NOTE: Please avoid to install language specific packages here (globally), instead, install them:
    # 1. per IDE, such as `programs.neovim.extraPackages`
    # 2. per-project, see https://github.com/the-nix-way/dev-templates

    # python313 # use https://github.com/the-nix-way/dev-templates?tab=readme-ov-file#python instead
    # yarn use https://github.com/the-nix-way/dev-templates?tab=readme-ov-file#node instead
    # mitmproxy # HTTP/HTTPS proxy tool
    # DB related
    # mycli
    # pgcli
    # mongosh
    # sqlite

    ## FPGA
    # python312Packages.apycula # gowin fpga
    # yosys # FPGA synthesis
    # nextpnr # FPGA place and route
    # openfpgaloader # FPGA programming

    # AI related
    # python313Packages.huggingface-hub # huggingface-cli

    # misc
    # devbox
    # bfg-repo-cleaner # remove large files from git history
    # k6 # load testing tool
    # protobuf # protocol buffer compiler

    # solve coding extercises - learn by doing
    # exercism

    # need to run `conda-install` before using it
    # need to run `conda-shell` before using command `conda`
    # conda is not available for MacOS
    # conda

    # android-tools
  ]
  ++ (if stdenv.hostPlatform.isRiscV64 then
    [pkgs.pkgs.deploy-rs]
  else [
    deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.deploy-rs
    pgp2ssh.packages.${pkgs.stdenv.hostPlatform.system}.pgp2ssh
  ]);
}
