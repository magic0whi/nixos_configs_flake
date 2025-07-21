{pkgs, myvars, ...}:
###########################################################
#
# Alacritty Configuration
#
# Useful Hot Keys for macOS:
#   1. Multi-Window: `command + N`
#   2. Increase Font Size: `command + =` | `command + +`
#   3. Decrease Font Size: `command + -` | `command + _`
#   4. Search Text: `command + F`
#   5. And Other common shortcuts such as Copy, Paste, Cursor Move, etc.
#
# Useful Hot Keys for Linux:
#   1. Increase Font Size: `ctrl + shift + =` | `ctrl + shift + +`
#   2. Decrease Font Size: `ctrl + shift + -` | `ctrl + shift + _`
#   3. Search Text: `ctrl + shift + N`
#   4. And Other common shortcuts such as Copy, Paste, Cursor Move, etc.
#
# Note: Alacritty do not have support for Tabs, and any graphic protocol.
#
###########################################################
{
  programs.alacritty = {
    enable = true;
    settings = { # https://alacritty.org/config-alacritty.html
      general.import = ["${pkgs.catppuccin}/alacritty/catppuccin-${myvars.catppuccin_variant}.toml"];
      window = {
        opacity = 0.93;
        startup_mode = "Maximized"; # Maximized window
        dynamic_title = true;
        option_as_alt = "Both"; # Option key acts as Alt on macOS
      };
      scrolling.history = 10000;
      font = {
        bold.family = "Iosevka Nerd Font Mono";
        bold_italic.family = "Iosevka Nerd Font Mono";
        italic.family = "Iosevka Nerd Font Mono";
        normal.family = "Iosevka Nerd Font Mono";
        size = if pkgs.stdenv.isDarwin then 14 else 12;
      };
      terminal = {
        # shell = { # Spawn a nushell in login mode via `bash`
        #   program = "${pkgs.bash}/bin/bash";
        #   args = ["--login" "-c" "nu --login --interactive"];
        # };
        osc52 = "CopyPaste"; # Controls the ability to write to the system clipboard with the OSC 52 escape sequence. It's used by zellij to copy text to the system clipboard.
      };
    };
  };
}
