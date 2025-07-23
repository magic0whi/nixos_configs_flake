{pkgs, lib, ...}: {
  programs.ghostty = { # terminal emulator
    enable = true;
    # As of Jun 1, 2025, pkgs.ghostty is still marked as broken on MacOS (aarch64-darwin)
    # TIP: Use `pkgs.emptyFile` (or `pkgs.emptyDirectory` or `null` if formers don't work) as a dummy package
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    settings = { # https://ghostty.org/docs/config/reference
      keybind = [
        "alt+left=unbind"
        "alt+right=unbind"
      ];
      font-family = "Iosevka Nerd Font Mono";
      font-size = 13;
      scrollback-limit = 20000;
    } // lib.optionalAttrs pkgs.stdenv.isDarwin { # Only supported on macOS
      macos-option-as-alt = "left";
      background-opacity = 0.93;
      background-blur = true;
    };
  };
}
