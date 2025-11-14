{pkgs, config, myvars, ...}: {
  # If your themes for mouse cursor, icons or windows don’t load correctly, try setting them with home.pointerCursor and
  # gtk.theme, which enable a bunch of compatibility options that should make the themes load in all situations.
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };
  xresources.properties = { # Set DPI for 4k monitor
    # "Xft.dpi" = 150; # dpi for Xorg's font
    "*.dpi" = 150; # or set a generic dpi
  };
  # gtk's theme settings, generate files:
  # ~/.gtkrc-2.0
  # ~/.config/gtk-3.0/settings.ini
  gtk = {
    enable = true;
    font = {
      name = "Inter Nerd Font";
      package = pkgs.inter-nerdfont;
      size = 11;
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
  };
  dconf.settings."org/gnome/desktop/interface" = { # GTK4
    color-scheme = "prefer-dark";
    # gtk-theme = "catppuccin-${myvars.catppuccin_variant}-${myvars.catppuccin_accent}-compact";
  };
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };
}
