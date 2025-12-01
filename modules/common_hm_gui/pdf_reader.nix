{pkgs, ...}: {
  programs = (if pkgs.stdenv.isDarwin then { # PDF reader
    sioyek = { # macOS
      enable = true;
      bindings = {
        screen_down = "<C-d>";
        screen_up = "<C-u>";
      };
    };
  } else { # Linux
    zathura = {
      enable = true;
      options.selection-clipboard = "clipboard";
    };
  });
}
