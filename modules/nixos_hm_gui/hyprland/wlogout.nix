{pkgs, lib, ...}: {
  options = {
    programs.wlogout.wrapper_script = lib.mkOption {
      type = lib.types.path;
      description = "Path to the wlogout wrapper script";
      default = pkgs.writeShellScript "wlogout" ''
        #!/usr/bin/env sh
        set -eufo pipefail

        LAYOUT="$HOME/.config/hypr/wlogout/layout"
        STYLE="$HOME/.config/hypr/wlogout/style.css"

        if ! pidof wlogout > /dev/null; then
          wlogout --layout "$LAYOUT" --css "$STYLE" \
            --column-spacing 20 \
            --row-spacing 20 \
            --margin-top 200 \
            --margin-bottom 200 \
            --margin-left 150 \
            --margin-right 150
        else
          pkill wlogout || true
        fi
      '';
    };
  };
}
