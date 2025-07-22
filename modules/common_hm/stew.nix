{lib, mylib, ...}: {
  ## START pip.nix
  # Use mirror for pip install
  xdg.configFile."pip/pip.conf".text = ''
  [global]
  index-url = https://mirror.nju.edu.cn/pypi/web/simple
  format = columns
  '';
  ## END pip.nix
  ## START zellij.nix
  programs.zellij.enable = lib.mkDefault true;
  home.shellAliases."zj" = "zellij";
  xdg.configFile."zellij/config.kdl".source = mylib.relative_to_root "custom_files/zellij.kdl";
  ## END zellij.nix
}
