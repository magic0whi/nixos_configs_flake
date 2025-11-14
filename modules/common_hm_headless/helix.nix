{pkgs, mylib, ...}: {
  programs = {
    helix = {
      enable = true;
      defaultEditor = true;
      extraPackages = with pkgs; [nil marksman ltex-ls texlab nodePackages.vscode-json-languageserver];
      settings = {
        # theme = "gruvbox"; # Disable if use catpuccin
        editor = {
          bufferline = "multiple";
          color-modes = true;
          cursorline = true;
          line-number = "relative";
          rulers = [80 120];
          true-color = true;
          soft-wrap.enable = true;
          cursor-shape.insert = "bar";
          file-picker.hidden = false;
          indent-guides.render = true;
          statusline = {
            left = ["mode" "spinner" "file-name" "read-only-indicator" "file-modification-indicator"];
            right = [
              "diagnostics" "version-control" "selections" "position" "file-encoding" "file-line-ending" "file-type"
            ];
          };
          whitespace.render = {
            space = "all";
            tab = "all";
            nbsp = "all";
            nnbsp = "all";
            newline = "none";
          };
        };
        keys = {
          insert."C-c" = "normal_mode";
          normal."C-r" = [":config-reload" ":lsp-restart"];
        };
      };
      languages = {
        language = [
          {name = "cpp"; auto-format = true;}
          {name = "markdown"; language-servers = ["marksman" "ltex"];}
          {name = "latex"; language-servers = ["texlab" "ltex"];}
        ];
        language-server = {
          ltex = {
            command = "ltex-ls";
            config.ltex = {
              language = "en-US";
              dictionary = builtins.fromTOML (
                builtins.readFile (mylib.relative_to_root "custom_files/ltex_dict.toml"));
            };
          };
          texlab.config.texlab = {
            chktex = {
              onOpenAndSave = true;
              onEdit = true;
            };
            forwardSearch = if pkgs.stdenv.isDarwin then { # SyncTeX for Darwin/NixOS
              executable = "sioyek";
              args = [
                "--reuse-window"
                "--execute-command" "toggle_synctex"
                "--inverse-search" "texlab inverse-search -i \"%%1\" -l %%2"
                "--forward-search-file" "%f" # %f is the source file
                "--forward-search-line" "%l" # %l is the line number in the source file
                "%p" # %p is the path to the generated PDF file
              ];
            } else {
              executable = "zathura";
              args = ["--synctex-forward" "%l:1:%f" "%p"];
            };
            build = {
              executable = "latexmk";
              args = ["-cd" "-pdflua" "-halt-on-error" "-interaction=nonstopmode" "-synctex=1" "%f"];
              onSave = true;
              forwardSearchAfter = true;
            };
          };
        };
      };
    };
  } // (if pkgs.stdenv.isDarwin then { # PDF reader
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
