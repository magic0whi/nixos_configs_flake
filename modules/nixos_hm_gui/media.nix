{pkgs, ...}: { # media - control and enjoy audio/video
  home.packages = with pkgs; [
    # audio control
    pavucontrol
    playerctl
    pulsemixer
    imv # simple image viewer

    # video/audio tools
    # cava # for visualizing audio
    libva-utils
    # vdpauinfo
    vulkan-tools
    glxinfo
    clinfo
  ];
  # # https://github.com/catppuccin/cava
  # xdg.configFile."cava/config".text = "# Custom cava config\n"
  #   + builtins.readFile "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-cava}/mocha.cava";
  services.playerctld.enable = true;
}
