{pkgs, ...}: {
  home.packages = with pkgs; [ # GUI apps
    # foliate # e-book viewer(.epub/.mobi/...),do not support .pdf
    localsend
    telegram-desktop # instant messaging
    # discord # update too frequently, use the web version instead

    # remote desktop(rdp connect)
    # remmina
    # freerdp # required by remmina

    # my custom hardened packages
    # pkgs.nixpaks.qq
    # pkgs.nixpaks.qq-desktop-item

    # wechat-uos
    # pkgs.nixpaks.wechat-uos
    # pkgs.nixpaks.wechat-uos-desktop-item
  ];
  # GitHub CLI tool
  # programs.gh.enable = true;
}
