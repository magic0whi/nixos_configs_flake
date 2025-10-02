{config, ...}: {
  services.jankyborders = {
    enable = true;
    settings = { # Highlight focused windows with colored borders
      active_color = "0xffe1e3e4";
      inactive_color = "0xff494d64";
      width = 5.0;
    };
  };
  xdg.configFile."aerospace/ghostty-actions.js".text = ''
  #!/usr/bin/osascript -l JavaScript
  ObjC.import('Foundation')
  const argv = $.NSProcessInfo.processInfo.arguments.js
  const system_events = Application('System Events');
  const term_path = '${config.programs.ghostty.package}/Applications/Ghostty.app';
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
    enable = true;
    userSettings = { # See https://nikitabobko.github.io/AeroSpace/guide#configuring-aerospace
      start-at-login = true;
      automatically-unhide-macos-hidden-apps = true; # Turn off macOS "Hide application" (cmd-h) feature
      gaps = {
        inner.horizontal = 3;
        inner.vertical = 3;
        outer.left = 3;
        outer.bottom = 3;
        outer.top = 3;
        outer.right = 3;
      };
      mode.main.binding = {
        # Run terminal
        alt-q = "exec-and-forget osascript -lJavaScript ${config.xdg.configHome}/aerospace/ghostty-actions.js 3";
        alt-shift-q = "exec-and-forget osascript -lJavaScript ${config.xdg.configHome}/aerospace/ghostty-actions.js 2";
        ctrl-alt-q = "exec-and-forget osascript -lJavaScript ${config.xdg.configHome}/aerospace/ghostty-actions.js 1";
        alt-w = "close";

        # See: https://nikitabobko.github.io/AeroSpace/commands#layout
        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";

        # Move focus, see: https://nikitabobko.github.io/AeroSpace/commands#focus
        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";
        alt-tab = "workspace-back-and-forth";
        alt-n = "workspace --wrap-around next";
        alt-p = "workspace --wrap-around prev";


        # Move windows, see: https://nikitabobko.github.io/AeroSpace/commands#move
        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        # Resize windows, See: https://nikitabobko.github.io/AeroSpace/commands#resize
        alt-ctrl-minus = "resize smart -50";
        alt-ctrl-equal = "resize smart +50";
        alt-shift-r = "mode resize";

        # Switch workpaces, see: https://nikitabobko.github.io/AeroSpace/commands#workspace
        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";
        alt-0 = "workspace 0";

        # Move active window to a workspace
        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-9 = "move-node-to-workspace 9";
        alt-shift-0 = "move-node-to-workspace 0";

        alt-shift-semicolon = "mode service"; # See: https://nikitabobko.github.io/AeroSpace/commands#mode
      };
      mode.service.binding = { # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
        esc = ["reload-config" "mode main"];
        f = [ "layout floating tiling" "mode main" ]; # Toggle between floating and tiling layout
        r = ["flatten-workspace-tree" "mode main"]; # reset layout
        backspace = ["close-all-windows-but-current" "mode main"];

        alt-shift-h = ["join-with left" "mode main"];
        alt-shift-j = ["join-with down" "mode main"];
        alt-shift-k = ["join-with up" "mode main"];
        alt-shift-l = ["join-with right" "mode main"];

        down = "volume down";
        up = "volume up";
        shift-down = ["volume set 0" "mode main"];
      };
      mode.resize.binding = { # 'resize' binding mode
        h = "resize width -50";
        j = "resize height +50";
        k = "resize height -50";
        l = "resize width +50";
        enter = "mode main";
        esc = "mode main";
      };
      exec.inherit-env-vars = true;
      workspace-to-monitor-force-assignment = {
        "1" = ["Built-in Retina Display"];
        "2" = ["Built-in Retina Display"];
        "3" = ["Built-in Retina Display"];
        "4" = ["Built-in Retina Display"];
      };
      on-window-detected = [
        {"if".app-id = "io.mpv"; run = ["layout floating"];}
        {"if".app-id = "com.valvesoftware.steam"; run = ["layout tiling"];}
      ];
    };
  };
}
