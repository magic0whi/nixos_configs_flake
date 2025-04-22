{pkgs, config, ...}: {
  # If your themes for mouse cursor, icons or windows don’t load correctly,
  # try setting them with home.pointerCursor and gtk.theme,
  # which enable a bunch of compatibility options that should make the themes load in all situations.

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };
  xresources.properties = { # set dpi for 4k monitor
    # "Xft.dpi" = 150; # dpi for Xorg's font
    "*.dpi" = 150; # or set a generic dpi
  };
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  # gtk's theme settings, generate files:
  #   1. ~/.gtkrc-2.0
  #   2. ~/.config/gtk-3.0/settings.ini
  #   3. ~/.config/gtk-4.0/settings.ini
  gtk = {
    enable = true;
    font = {
      name = "Inter Nerd Font";
      package = pkgs.inter-nerdfont;
      size = 11;
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "catppuccin-macchiato-pink-compact"; # https://github.com/catppuccin/gtk
      package = pkgs.catppuccin-gtk;
    };
  };
  qt = {
    enable = true;
    style.name = "gtk2";
  };
}
