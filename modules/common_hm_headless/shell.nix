{config, pkgs, lib, ...}: {
  home.packages = with pkgs; [
    tlrc # tldr written in Rust
    fd # search for files by name, faster than find
    (ripgrep.override {withPCRE2 = true;}) # search for files by its content, replacement of grep
  ];
  ## START zellij.nix
  programs.zellij = {
    enable = true;
    settings = {
      plugins = {
        tab-bar.path = "tab-bar";
        status-bar.path = "status-bar";
        strider.path = "strider";
        compact-bar.path = "compact-bar";
      };
      keybinds = {
        _props.clear-defaults = true;
        _children = [
          {shared_except = {
            _args = ["locked"];
            _children = [
              {bind = {_args = ["Ctrl g"]; SwitchToMode = "Locked";};}
              {bind = {_args = ["Ctrl q"]; Quit = {};};}
              {bind = {_args = ["Alt n"]; NewPane = {};};}
              {bind = {_args = ["Alt h" "Alt Left"]; MoveFocusOrTab = "Left";};}
              {bind = {_args = ["Alt j" "Alt Down"]; MoveFocus = "Down";};}
              {bind = {_args = ["Alt k" "Alt Up"]; MoveFocus = "Up";};}
              {bind = {_args = ["Alt l" "Alt Right"]; MoveFocusOrTab = "Right";};}
              {bind = {_args = ["Alt =" "Alt +"]; Resize = "Increase";};}
              {bind = {_args = ["Alt -" "Alt _"]; Resize = "Decrease";};}
              {bind = {_args = ["Alt ["]; PreviousSwapLayout = {};};}
              {bind = {_args = ["Alt ]"]; NextSwapLayout = {};};}
            ];
          };}
          {shared_except = {
            _args = ["normal" "locked"];
            bind = {_args = ["Enter" "Esc"]; SwitchToMode = "Normal";};
          };}
          {shared_except = {
            _args = ["pane" "locked"];
            bind = {_args = ["Ctrl p"]; SwitchToMode = "Pane";};
          };}
          {shared_except = {
            _args = ["resize" "locked"];
            bind = {_args = ["Ctrl n"]; SwitchToMode = "Resize";};
          };}
          {shared_except = {
            _args = ["scroll" "locked"];
            bind = {_args = ["Ctrl s"]; SwitchToMode = "Scroll";};
          };}
          {shared_except = {
            _args = ["session" "locked"];
            bind = {_args = ["Ctrl o"]; SwitchToMode = "Session";};
          };}
          {shared_except = {
            _args = ["tab" "locked"];
            bind = {_args = ["Ctrl t"]; SwitchToMode = "Tab";};
          };}
          {shared_except = {
            _args = ["move" "locked"];
            bind = {_args = ["Ctrl h"]; SwitchToMode = "Move";};
          };}
          # {shared_except = {
          #   _args = ["tmux" "locked"];
          #   bind = {_args = ["Ctrl b"]; SwitchToMode = "Tmux";};
          # };}
        ];
        # Uncomment this and adjust key if using copy_on_select=false
        # normal.bind = {_args = ["Alt c"]; Copy = {};};
        locked.bind = {_args = ["Ctrl g"]; SwitchToMode = "Normal";};
        resize._children = [
          {bind = {_args = ["Ctrl n"]; SwitchToMode = "Normal";};}
          {bind = {_args = ["h" "Left"]; Resize = "Increase Left";};}
          {bind = {_args = ["j" "Down"]; Resize = "Increase Down";};}
          {bind = {_args = ["k" "Up"]; Resize = "Increase Up";};}
          {bind = {_args = ["l" "Right"]; Resize = "Increase Right";};}
          {bind = {_args = ["H"]; Resize = "Decrease Left";};}
          {bind = {_args = ["J"]; Resize = "Decrease Down";};}
          {bind = {_args = ["K"]; Resize = "Decrease Up";};}
          {bind = {_args = ["L"]; Resize = "Decrease Right";};}
          {bind = {_args = ["=" "+"]; Resize = "Increase";};}
          {bind = {_args = ["-" "_"]; Resize = "Decrease";};}
        ];
        pane._children = [
          {bind = {_args = ["Ctrl p"]; SwitchToMode = "Normal";};}
          {bind = {_args = ["h" "Left"]; MoveFocus = "Left";};}
          {bind = {_args = ["j" "Down"]; MoveFocus = "Down";};}
          {bind = {_args = ["k" "Up"]; MoveFocus = "Up";};}
          {bind = {_args = ["l" "Right"]; MoveFocus = "Right";};}
          {bind = {_args = ["p"]; SwitchFocus = {};};}
          {bind = {
            _args = ["n"];
            _children = [{NewPane = {};}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["d"];
            _children = [{NewPane = "Down";}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["r"];
            _children = [{NewPane = "Right";}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["x"];
            _children = [{CloseFocus = {};}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["f"];
            _children = [{ToggleFocusFullscreen = {};}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["z"];
            _children = [{TogglePaneFrames = {};}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["w"];
            _children = [{ToggleFloatingPanes = {};}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["e"];
            _children = [{TogglePaneEmbedOrFloating = {};}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["c"];
            _children = [{SwitchToMode = "RenamePane";}{PaneNameInput = 0;}];
          };}
        ];
        move._children = [
          {bind = {_args = ["Ctrl h"]; SwitchToMode = "Normal";};}
          {bind = {_args = ["n" "Tab"]; MovePane = {};};}
          {bind = {_args = ["p"]; MovePaneBackwards = {};};}
          {bind = {_args = ["h" "Left"]; MovePane = "Left";};}
          {bind = {_args = ["j" "Down"]; MovePane = "Down";};}
          {bind = {_args = ["k" "Up"]; MovePane = "Up";};}
          {bind = {_args = ["l" "Right"]; MovePane = "Right";};}
        ];
        tab._children = [
          {bind = {_args = ["Ctrl t"]; SwitchToMode = "Normal";};}
          {bind = {
            _args = ["r"];
            _children = [{SwitchToMode = "RenameTab";}{TabNameInput = 0;}];
          };}
          {bind = {_args = ["h" "Left" "k" "Up"]; GoToPreviousTab = {};};}
          {bind = {_args = ["l" "Right" "j" "Down"]; GoToNextTab = {};};}
          {bind = {
            _args = ["n"];
            _children = [{NewTab = {};}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["x"];
            _children = [{CloseTab = {};}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["s"];
            _children = [{ToggleActiveSyncTab = {};}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["1"];
            _children = [{GoToTab = 1;}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["2"];
            _children = [{GoToTab = 2;}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["3"];
            _children = [{GoToTab = 3;}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["4"];
            _children = [{GoToTab = 4;}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["5"];
            _children = [{GoToTab = 5;}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["6"];
            _children = [{GoToTab = 6;}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["7"];
            _children = [{GoToTab = 7;}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["8"];
            _children = [{GoToTab = 8;}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["9"];
            _children = [{GoToTab = 9;}{SwitchToMode = "Normal";}];
          };}
          {bind = {_args = ["Tab"]; ToggleTab = {};};}
        ];
        scroll._children = [
          {bind = {_args = ["Ctrl s"]; SwitchToMode = "Normal";};}
          {bind = {
            _args = ["e"];
            _children = [{EditScrollback = {};}{SwitchToMode = "Normal";}];
          };}
          {bind = {
            _args = ["s"];
            _children = [{SwitchToMode = "EnterSearch";}{SearchInput = 0;}];
          };}
          {bind = {
            _args = ["Ctrl c"];
            _children = [{ScrollToBottom = {};}{SwitchToMode = "Normal";}];
          };}
          {bind = {_args = ["j" "Down"]; ScrollDown = {};};}
          {bind = {_args = ["k" "Up"]; ScrollUp = {};};}
          {bind = {_args = ["Ctrl f" "PageDown" "l" "Right"]; PageScrollDown = {};};}
          {bind = {_args = ["Ctrl b" "PageUp" "h" "Left"]; PageScrollUp = {};};}
          {bind = {_args = ["d" "Ctrl d"]; HalfPageScrollDown = {};};}
          {bind = {_args = ["u" "Ctrl u"]; HalfPageScrollUp = {};};}
          # Uncomment this and adjust key if using copy_on_select=false
          # {bind = {_args = ["Alt c"]; Copy = {};};}
        ];
        search._children = [
          {bind = {_args = ["Ctrl s"]; SwitchToMode = "Normal";};}
          {bind = {
            _args = ["Ctrl c"];
            _children = [{ScrollToBottom = {};}{SwitchToMode = "Normal";}];
          };}
          {bind = {_args = ["j" "Down"]; ScrollDown = {};};}
          {bind = {_args = ["k" "Up"]; ScrollUp = {};};}
          {bind = {_args = ["Ctrl f" "PageDown" "l" "Right"]; PageScrollDown = {};};}
          {bind = {_args = ["Ctrl b" "PageUp" "h" "Left"]; PageScrollUp = {};};}
          {bind = {_args = ["d" "Ctrl d"]; HalfPageScrollDown = {};};}
          {bind = {_args = ["u" "Ctrl u"]; HalfPageScrollUp = {};};}
          {bind = {_args = ["n"]; Search = "Down";};}
          {bind = {_args = ["N"]; Search= "Up";};}
          {bind = {_args = ["c"]; SearchToggleOption = "CaseSensitivity";};}
          {bind = {_args = ["w"]; SearchToggleOption = "Wrap";};}
          {bind = {_args = ["o"]; SearchToggleOption = "WholeWord";};}
        ];
        entersearch._children = [
          {bind = {_args = ["Ctrl c" "Esc"]; SwitchToMode = "Scroll";};}
          {bind = {_args = ["Enter"]; SwitchToMode = "Search";};}
        ];
        renametab._children = [
          {bind = {_args = ["Ctrl c"]; SwitchToMode = "Normal";};}
          {bind = {
            _args = ["Esc"];
            _children = [{UndoRenameTab = {};}{SwitchToMode = "Tab";}];
          };}
        ];
        renamepane._children = [
          {bind = {_args = ["Ctrl c"]; SwitchToMode = "Normal";};}
          {bind = {
            _args = ["Esc"];
            _children = [{UndoRenamePane = {};}{SwitchToMode = "Pane";}];
          };}
        ];
        session._children = [
          {bind = {_args = ["Ctrl o"]; SwitchToMode = "Normal";};}
          {bind = {_args = ["Ctrl s"]; SwitchToMode = "Scroll";};}
          {bind = {_args = ["d"]; Detach = {};};}
        ];
        # tmux._children = [
        #   {bind = {_args = ["["]; SwitchToMode = "Scroll";};}
        #   {bind = {
        #     _args = ["Ctrl b"];
        #     _children = [{Write = 2;}{SwitchToMode = "Normal";}];
        #   };}
        #   {bind = {
        #     _args = ["\""];
        #     _children = [{NewPane = "Down";}{SwitchToMode = "Normal";}];
        #   };}
        #   {bind = {
        #     _args = ["%"];
        #     _children = [{NewPane = "Right";}{SwitchToMode = "Normal";}];
        #   };}
        #   {bind = {
        #     _args = ["z"];
        #     _children = [{ToggleFocusFullscreen = {};}{SwitchToMode = "Normal";}];
        #   };}
        #   {bind = {
        #     _args = ["c"];
        #     _children = [{NewTab = {};}{SwitchToMode = "Normal";}];
        #   };}
        #   {bind = {_args = [","]; SwitchToMode = "RenameTab";};}
        #   {bind = {
        #     _args = ["p"];
        #     _children = [{GoToPreviousTab = {};}{SwitchToMode = "Normal";}];
        #   };}
        #   {bind = {
        #     _args = ["n"];
        #     _children = [{GoToNextTab = {};}{SwitchToMode = "Normal";}];
        #   };}
        #   {bind = {
        #     _args = ["h" "Left"];
        #     _children = [{MoveFocus = "Left";}{SwitchToMode = "Normal";}];
        #   };}
        #   {bind = {
        #     _args = ["j" "Down"];
        #     _children = [{MoveFocus = "Down";}{SwitchToMode = "Normal";}];
        #   };}
        #   {bind = {
        #     _args = ["k" "Up"];
        #     _children = [{MoveFocus = "Up";}{SwitchToMode = "Normal";}];
        #   };}
        #   {bind = {
        #     _args = ["l" "Right"];
        #     _children = [{MoveFocus = "Right";}{SwitchToMode = "Normal";}];
        #   };}
        #   {bind = {_args = ["o"]; FocusNextPane = {};};}
        #   {bind = {_args = ["d"]; Detach = {};};}
        #   {bind = {_args = ["Space"]; NextSwapLayout = {};};}
        #   {bind = {
        #     _args = ["x"];
        #     _children = [{CloseFocus = {};}{SwitchToMode = "Normal";}];
        #   };}
        # ];
      };
    };
  };
  home.shellAliases."zj" = "zellij";
  ## END zellij.nix

  home.sessionVariables = { # Environment variables that always set at login
    LESS = "-R -N";
    LESSHISTFILE = config.xdg.cacheHome + "/less/history";
    LESSKEY = config.xdg.configHome + "/less/lesskey";
    WINEPREFIX = config.xdg.dataHome + "/wine";
    DELTA_PAGER = "less -R"; # Enable scrolling in git diff
  };
  home.shellAliases = {
    k = "kubectl";
    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    grep = "grep --color=auto";
    # ip = "ip --color=auto"; # `iproute2mac` doesn't support color, as of 7/22/2025
    cp = "cp -i";
    bc = "bc -lq";
    cpr = "rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 \"$@\"";
    mvr = "rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 --remove-source-files \"$@\"";
    diff = "command diff --text --unified --new-file --color=auto \"$@\"";
    man = "MANPAGER=\"less -R --use-color -Dd+r -Du+b\"" # Set boldface -> red color, underline -> blue color
      + " MANROFFOPT=\"-P-c\"" # Enables groff's "continuous" (non-paginated) output mode
      + " MANWIDTH=$(($(tput cols) - 7))" # Adjustment manwidth when less' line number enabled
      + " command man \"$@\"";
  };
  programs = {
    zsh = {
      enable = true;
      package = pkgs.emptyDirectory;
      autosuggestion = {
        enable = true;
        highlight = "fg=60";
        strategy = ["match_prev_cmd" "history" "completion"];
      };
      initContent = let
        local_bin = "${config.home.homeDirectory}/.local/bin";
        go_bin = "${config.home.homeDirectory}/go/bin";
        rust_bin = "${config.home.homeDirectory}/.cargo/bin";
      in lib.mkAfter ''export PATH="$PATH:${local_bin}:${go_bin}:${rust_bin}"'';
    };
    eza = { # A modern replacement for ‘ls’, useful in bash/zsh prompt, but not in nushell
      enable = if pkgs.stdenv.hostPlatform.isRiscV64 then false else true;
      git = true;
      icons = "auto";
    };
    bat = { # a cat-like with syntax highlighting and Git integration.
      enable = true;
      config = {
        pager = "less -FR";
      };
    };
    # A command-line fuzzy finder. Interactively filter its input using fuzzy searching, not limit to filenames.
    fzf = {
      enable = true;
      defaultOptions = ["-m"];
      defaultCommand = "rg --files"; # Using ripgrep in fzf
    };
    # zoxide is a smarter cd command, inspired by z and autojump.
    # It remembers which directories you use most frequently,
    # so you can "jump" to them in just a few keystrokes.
    # zoxide works on all major shells.
    #
    #   z foo              # cd into highest ranked directory matching foo
    #   z foo bar          # cd into highest ranked directory matching foo and bar
    #   z foo /            # cd into a subdirectory starting with foo
    #
    #   z ~/foo            # z also works like a regular cd command
    #   z foo/             # cd into relative path
    #   z ..               # cd one level up
    #   z -                # cd into previous directory
    #
    #   zi foo             # cd with interactive selection (using fzf)
    #
    #   z foo<SPACE><TAB>  # show interactive completions (zoxide v0.8.0+, bash 4.4+/fish/zsh only)
    zoxide.enable = true;

    # Atuin replaces your existing shell history with a SQLite database,
    # and records additional context for your commands.
    # Additionally, it provides optional and fully encrypted
    # synchronisation of your history between machines, via an Atuin server.
    atuin.enable = true;
    atuin.settings.sync_address = "https://atuin.proteus.eu.org";
    starship = {
      enable = true;
      settings = {
        add_newline = false;
        line_break.disabled = true;
        status.disabled = false;
        character.success_symbol = "[➜ ](bold green)";
        character.error_symbol = "[✗ ](bold red)";
        aws.disabled = true;
        aws.symbol = "🅰 ";
        gcloud = {
          disabled = true;
          # Do not show the account/project's info to avoid the leak of sensitive information when sharing the
          # terminal
          format = "on [$symbol$active(\($region\))]($style) ";
          symbol = "🅶 ️";
        };
        hostname.ssh_only = false;
        hostname.format = "[$ssh_symbol$hostname]($style) ";
        time.disabled = false;
        time.format = "[$time]($style)";
        right_format = "[$status$time]($style)";
        username.format = "[$user]($style) @ ";
        username.show_always = true;
      };
    };
    # tmux = {
    #   enable = true;
    #   keyMode = "vi";
    #   customPaneNavigationAndResize = true;
    #   shortcut = "a";
    # };
  };
}
