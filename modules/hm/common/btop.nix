{lib, myvars, ...}: with lib; {
  # https://github.com/catppuccin/btop/blob/main/themes/catppuccin_mocha.theme
  xdg.configFile."btop/themes".source = "${myvars.catppuccin}/btop/";
  programs.btop = { # Alternative to htop/nmon
    enable = mkDefault true;
    settings = {
      color_theme = mkDefault "catppuccin_${myvars.catppuccin_variant}";
      theme_background = mkDefault false; # Make btop transparent
    };
  };
}
