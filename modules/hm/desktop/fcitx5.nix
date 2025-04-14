{pkgs, nur-ryan4yin, ...}: {
  home.file.".local/share/fcitx5/themes".source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-fcitx5}/src";

  xdg.configFile = {
    "fcitx5/profile" = {
      source = ./fcitx5-profile;
      force = true; # every time fcitx5 switch input method, it will modify ~/.config/fcitx5/profile, so we need to force replace it in every rebuild to avoid file conflict.
    };
    "fcitx5/conf/classicui.conf".source = ./fcitx5-classicui.conf;
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.waylandFrontend = true; # TODO
    fcitx5.addons = with pkgs; [
      fcitx5-configtool # needed enable rime using configtool after installed
      fcitx5-chinese-addons fcitx5-chewing fcitx5-mozc fcitx5-rime
      fcitx5-pinyin-zhwiki fcitx5-pinyin-moegirl fcitx5-pinyin-minecraft
      fcitx5-gtk # gtk im module
    ];
  };
}
