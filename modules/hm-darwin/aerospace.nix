{config, lib, ...}: with lib; {
  services.jankyborders.enable = mkDefault true;
  xdg.configFile."aerospace/ghostty-actions.js".text = mkDefault ''
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
    enable = mkDefault true;
    userSettings = { # See https://nikitabobko.github.io/AeroSpace/guide#configuring-aerospace
      start-at-login = mkDefault true;
      after-startup-command = [ # Available commands https://nikitabobko.github.io/AeroSpace/commands
        "exec-and-forget borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=5.0" # Highlight focused windows with colored borders TODO: move to services.jankyborders.settings
      ];
      automatically-unhide-macos-hidden-apps = mkDefault true; # Turn off macOS "Hide application" (cmd-h) feature
      gaps = {
        inner.horizontal = mkDefault 3;
        inner.vertical = mkDefault 3;
        outer.left = mkDefault 3;
        outer.bottom = mkDefault 3;
        outer.top = mkDefault 3;
        outer.right = mkDefault 3;
      };
      mode.main.binding = {
        # Run terminal
        ctrl-alt-q = mkDefault "exec-and-forget osascript -lJavaScript ${config.xdg.configHome}/aerospace/ghostty-actions.js 1";
        alt-shift-q = mkDefault "exec-and-forget osascript -lJavaScript ${config.xdg.configHome}/aerospace/ghostty-actions.js 2";
        alt-q = mkDefault "exec-and-forget osascript -lJavaScript ${config.xdg.configHome}/aerospace/ghostty-actions.js 3";

        # See: https://nikitabobko.github.io/AeroSpace/commands#layout
        alt-slash = mkDefault "layout tiles horizontal vertical";
        alt-comma = mkDefault "layout accordion horizontal vertical";
        alt-w = mkDefault "close";

        # See: https://nikitabobko.github.io/AeroSpace/commands#focus
        alt-h = mkDefault "focus left";
        alt-j = mkDefault "focus down";
        alt-k = mkDefault "focus up";
        alt-l = mkDefault "focus right";

        # See: https://nikitabobko.github.io/AeroSpace/commands#move
        alt-shift-h = mkDefault "move left";
        alt-shift-j = mkDefault "move down";
        alt-shift-k = mkDefault "move up";
        alt-shift-l = mkDefault "move right";

        # See: https://nikitabobko.github.io/AeroSpace/commands#resize
        alt-shift-minus = mkDefault "resize smart -50";
        alt-shift-equal = mkDefault "resize smart +50";
        alt-shift-r = mkDefault "mode resize";

        # See: https://nikitabobko.github.io/AeroSpace/commands#workspace
        alt-1 = mkDefault "workspace 1";
        alt-2 = mkDefault "workspace 2";
        alt-3 = mkDefault "workspace 3";
        alt-4 = mkDefault "workspace 4";
        alt-5 = mkDefault "workspace 5";
        alt-6 = mkDefault "workspace 6";
        alt-7 = mkDefault "workspace 7";
        alt-8 = mkDefault "workspace 8";
        alt-9 = mkDefault "workspace 9";
        alt-0 = mkDefault "workspace 0";

        alt-shift-1 = mkDefault "move-node-to-workspace 1";
        alt-shift-2 = mkDefault "move-node-to-workspace 2";
        alt-shift-3 = mkDefault "move-node-to-workspace 3";
        alt-shift-4 = mkDefault "move-node-to-workspace 4";
        alt-shift-5 = mkDefault "move-node-to-workspace 5";
        alt-shift-6 = mkDefault "move-node-to-workspace 6";
        alt-shift-7 = mkDefault "move-node-to-workspace 7";
        alt-shift-8 = mkDefault "move-node-to-workspace 8";
        alt-shift-9 = mkDefault "move-node-to-workspace 9";
        alt-shift-0 = mkDefault "move-node-to-workspace 0";

        alt-tab = mkDefault "workspace-back-and-forth";
        alt-shift-tab = mkDefault "move-workspace-to-monitor --wrap-around next"; # See: https://nikitabobko.github.io/AeroSpace/commands#move-workspace-to-monitor

        alt-shift-semicolon = mkDefault "mode service"; # See: https://nikitabobko.github.io/AeroSpace/commands#mode
      };
      mode.service.binding = { # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
        esc = mkDefault ["reload-config" "mode main"];
        f = mkDefault [ "layout floating tiling" "mode main" ]; # Toggle between floating and tiling layout
        r = mkDefault ["flatten-workspace-tree" "mode main"]; # reset layout
        backspace = mkDefault ["close-all-windows-but-current" "mode main"];

        alt-shift-h = mkDefault ["join-with left" "mode main"];
        alt-shift-j = mkDefault ["join-with down" "mode main"];
        alt-shift-k = mkDefault ["join-with up" "mode main"];
        alt-shift-l = mkDefault ["join-with right" "mode main"];

        down = mkDefault "volume down";
        up = mkDefault "volume up";
        shift-down = mkDefault ["volume set 0" "mode main"];
      };
      mode.resize.binding = { # 'resize' binding mode
        h = mkDefault "resize width -50";
        j = mkDefault "resize height +50";
        k = mkDefault "resize height -50";
        l = mkDefault "resize width +50";
        enter = mkDefault "mode main";
        esc = mkDefault "mode main";
      };
      exec.inherit-env-vars = mkDefault true;
      workspace-to-monitor-force-assignment = {
        "1" = mkDefault ["Built-in Retina Display"];
        "2" = mkDefault ["Built-in Retina Display"];
        "3" = mkDefault ["Built-in Retina Display"];
        "4" = mkDefault ["Built-in Retina Display"];
      };
      on-window-detected = [
        {
          "if".app-id = "io.mpv";
          run = ["layout floating"];
        }
      ];
    };
  };
}
