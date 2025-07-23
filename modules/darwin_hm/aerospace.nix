{config, lib, ...}: {
  services.jankyborders = {
    enable = lib.mkDefault true;
    settings = { # Highlight focused windows with colored borders
      active_color = lib.mkDefault "0xffe1e3e4";
      inactive_color = lib.mkDefault "0xff494d64";
      width = lib.mkDefault 5.0;
    };
  };
  xdg.configFile."aerospace/ghostty-actions.js".text = ''
  #!/usr/bin/osascript -l JavaScript
  ObjC.import('Foundation')
  const argv = $.NSProcessInfo.processInfo.arguments.js
  const system_events = Application('System Events');
  const term_path = '/nix/store/s8cwz1gr50bp09dqs1wjdharfsxryp6z-ghostty-bin-1.1.3/Applications/Ghostty.app';
  function quick_term() {
    const ghostty = system_events.processes.byName('Ghostty');
    const menu_bar_view_quick_term = ghostty.menuBars[0].menuBarItems['View'].menus[0].menuItems['Quick Terminal'];
    menu_bar_view_quick_term.click();
  }
  function new_window() {
    const ghostty = system_events.processes.byName('Ghostty');
    const menu_bar_file_new_window = ghostty.menuBars[0].menuBarItems['File'].menus[0].menuItems['New Window'];
    menu_bar_file_new_window.click();
  }
  function run(argv) {
    var ghostty = null;
    switch (Application(term_path).running()) { // Assure Ghostty is running
      case false: ghostty = Application(term_path); delay(0.2); break; // Short delay to wait for the Ghostty launch
      case true: ghostty = Application(term_path); // Launch Ghostty
    }
    argv.forEach((arg, idx) => {
      switch(arg) {
        case "1": ghostty.activate(); break; // Focus Ghostty
        case "2": quick_term(); break; // Quich Terminal
        case "3": new_window();
      }
    });
  }
  '';
  programs.aerospace = {
    enable = lib.mkDefault true;
    userSettings = { # See https://nikitabobko.github.io/AeroSpace/guide#configuring-aerospace
      start-at-login = lib.mkDefault true;
      automatically-unhide-macos-hidden-apps = lib.mkDefault true; # Turn off macOS "Hide application" (cmd-h) feature
      gaps = {
        inner.horizontal = lib.mkDefault 3;
        inner.vertical = lib.mkDefault 3;
        outer.left = lib.mkDefault 3;
        outer.bottom = lib.mkDefault 3;
        outer.top = lib.mkDefault 3;
        outer.right = lib.mkDefault 3;
      };
      mode.main.binding = {
        # Run terminal
        alt-q = lib.mkDefault "exec-and-forget osascript -lJavaScript ${config.xdg.configHome}/aerospace/ghostty-actions.js 3";
        alt-shift-q = lib.mkDefault "exec-and-forget osascript -lJavaScript ${config.xdg.configHome}/aerospace/ghostty-actions.js 2";
        ctrl-alt-q = lib.mkDefault "exec-and-forget osascript -lJavaScript ${config.xdg.configHome}/aerospace/ghostty-actions.js 1";
        alt-w = lib.mkDefault "close";

        # See: https://nikitabobko.github.io/AeroSpace/commands#layout
        alt-slash = lib.mkDefault "layout tiles horizontal vertical";
        alt-comma = lib.mkDefault "layout accordion horizontal vertical";

        # Move focus, see: https://nikitabobko.github.io/AeroSpace/commands#focus
        alt-h = lib.mkDefault "focus left";
        alt-j = lib.mkDefault "focus down";
        alt-k = lib.mkDefault "focus up";
        alt-l = lib.mkDefault "focus right";
        alt-tab = lib.mkDefault "workspace-back-and-forth";
        alt-n = lib.mkDefault "workspace --wrap-around next";
        alt-p = lib.mkDefault "workspace --wrap-around prev";


        # Move windows, see: https://nikitabobko.github.io/AeroSpace/commands#move
        alt-shift-h = lib.mkDefault "move left";
        alt-shift-j = lib.mkDefault "move down";
        alt-shift-k = lib.mkDefault "move up";
        alt-shift-l = lib.mkDefault "move right";

        # Resize windows, See: https://nikitabobko.github.io/AeroSpace/commands#resize
        alt-ctrl-minus = lib.mkDefault "resize smart -50";
        alt-ctrl-equal = lib.mkDefault "resize smart +50";
        alt-shift-r = lib.mkDefault "mode resize";

        # Switch workpaces, see: https://nikitabobko.github.io/AeroSpace/commands#workspace
        alt-1 = lib.mkDefault "workspace 1";
        alt-2 = lib.mkDefault "workspace 2";
        alt-3 = lib.mkDefault "workspace 3";
        alt-4 = lib.mkDefault "workspace 4";
        alt-5 = lib.mkDefault "workspace 5";
        alt-6 = lib.mkDefault "workspace 6";
        alt-7 = lib.mkDefault "workspace 7";
        alt-8 = lib.mkDefault "workspace 8";
        alt-9 = lib.mkDefault "workspace 9";
        alt-0 = lib.mkDefault "workspace 0";

        # Move active window to a workspace
        alt-shift-1 = lib.mkDefault "move-node-to-workspace 1";
        alt-shift-2 = lib.mkDefault "move-node-to-workspace 2";
        alt-shift-3 = lib.mkDefault "move-node-to-workspace 3";
        alt-shift-4 = lib.mkDefault "move-node-to-workspace 4";
        alt-shift-5 = lib.mkDefault "move-node-to-workspace 5";
        alt-shift-6 = lib.mkDefault "move-node-to-workspace 6";
        alt-shift-7 = lib.mkDefault "move-node-to-workspace 7";
        alt-shift-8 = lib.mkDefault "move-node-to-workspace 8";
        alt-shift-9 = lib.mkDefault "move-node-to-workspace 9";
        alt-shift-0 = lib.mkDefault "move-node-to-workspace 0";

        alt-shift-semicolon = lib.mkDefault "mode service"; # See: https://nikitabobko.github.io/AeroSpace/commands#mode
      };
      mode.service.binding = { # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
        esc = lib.mkDefault ["reload-config" "mode main"];
        f = lib.mkDefault [ "layout floating tiling" "mode main" ]; # Toggle between floating and tiling layout
        r = lib.mkDefault ["flatten-workspace-tree" "mode main"]; # reset layout
        backspace = lib.mkDefault ["close-all-windows-but-current" "mode main"];

        alt-shift-h = lib.mkDefault ["join-with left" "mode main"];
        alt-shift-j = lib.mkDefault ["join-with down" "mode main"];
        alt-shift-k = lib.mkDefault ["join-with up" "mode main"];
        alt-shift-l = lib.mkDefault ["join-with right" "mode main"];

        down = lib.mkDefault "volume down";
        up = lib.mkDefault "volume up";
        shift-down = lib.mkDefault ["volume set 0" "mode main"];
      };
      mode.resize.binding = { # 'resize' binding mode
        h = lib.mkDefault "resize width -50";
        j = lib.mkDefault "resize height +50";
        k = lib.mkDefault "resize height -50";
        l = lib.mkDefault "resize width +50";
        enter = lib.mkDefault "mode main";
        esc = lib.mkDefault "mode main";
      };
      exec.inherit-env-vars = lib.mkDefault true;
      workspace-to-monitor-force-assignment = {
        "1" = lib.mkDefault ["Built-in Retina Display"];
        "2" = lib.mkDefault ["Built-in Retina Display"];
        "3" = lib.mkDefault ["Built-in Retina Display"];
        "4" = lib.mkDefault ["Built-in Retina Display"];
      };
      on-window-detected = [
        {"if".app-id = "io.mpv"; run = ["layout floating"];}
      ];
    };
  };
}
