{pkgs, deploy-rs, ...}: {
  #############################################################
  #
  #  Basic settings for development environment
  #
  #  Please avoid to install language specific packages here(globally),
  #  instead, install them:
  #     1. per IDE, such as `programs.neovim.extraPackages`
  #     2. per-project, using https://github.com/the-nix-way/dev-templates
  #
  #############################################################
  home.packages = with pkgs; [
    deploy-rs.packages.${pkgs.system}.deploy-rs

    python312
    # db related
    # mycli
    # pgcli
    # mongosh
    # sqlite

    # embedded development
    # minicom

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
  ];
  # programs = {
  #   direnv = {
  #     enable = true;
  #     nix-direnv.enable = true;
  #   };
  # };
}
