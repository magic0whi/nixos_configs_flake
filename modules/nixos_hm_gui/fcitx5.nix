{pkgs, ...}: {
  xdg.configFile = {
    "fcitx5/profile" = {
      source = ./fcitx5-profile;
      force = true; # every time fcitx5 switch input method, it will modify ~/.config/fcitx5/profile, so we need to force replace it in every rebuild to avoid file conflict.
    };
    "fcitx5/conf/classicui.conf".source = ./fcitx5-classicui.conf;
  };
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true; # Hyprland supports it
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-configtool # needed enable rime using configtool after installed
      qt6Packages.fcitx5-chinese-addons
      fcitx5-chewing fcitx5-mozc fcitx5-rime
      fcitx5-pinyin-zhwiki fcitx5-pinyin-moegirl fcitx5-pinyin-minecraft
      fcitx5-gtk catppuccin-fcitx5 # GTK IM module
    ];
  };
}
