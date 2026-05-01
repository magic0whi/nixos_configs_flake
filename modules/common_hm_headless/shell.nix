{config, pkgs, lib, ...}: {
  home.packages = with pkgs; [
    tlrc # tldr written in Rust
    fd # search for files by name, faster than find
    (ripgrep.override {withPCRE2 = true;}) # search for files by its content, replacement of grep
  ];
  home.sessionVariables = { # Environment variables that always set at login
    # Disable line-number since I use bat mostly and this will cause double line
    # numbering
    # LESS = "-R -N";
    LESS = "-R";
    LESSHISTFILE = config.xdg.cacheHome + "/less/history";
    LESSKEY = config.xdg.configHome + "/less/lesskey";
    WINEPREFIX = config.xdg.dataHome + "/wine";
    DELTA_PAGER = "less -R"; # Enable scrolling in git diff
  };
  home.shellAliases = {
    k = "kubectl";
    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    # `programs.eza.enable*Integration` overrides these
    # ls = "ls --color=auto -v";
    # ll = "ls -l --color=auto -v";
    # la = "ls -la --color=auto -v";
    # lh = "ls -lah --color=auto -v";
    grep = "grep --color=auto";
    ip = "ip --color=auto";
    cp = "cp -i";
    bc = "bc -lq"; # `-l` load ath lib, `-q` quiet
    cpr = "rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1";
    mvr = "rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 --remove-source-files";
    diff = "diff --text --expand-tabs --unified --new-file --recursive --color=auto";
    # For `git filter-branch --help | bat -l man`, use
    # `MANWIDTH=999 git filter-branch --help | bat -lman` instead to prevent
    # git from baking ugly line breaks
    man = "MANPAGER=\"less -R --use-color -Dd+r -Du+b\"" # Set boldface -> red color, underline -> blue color
      + " MANROFFOPT=\"-P-c\"" # Enables groff's "continuous" (non-paginated) output mode
      + " MANWIDTH=$(($(tput cols) - 7))" # Adjustment manwidth when less' line number enabled
      + " command man";
    llag = "eza -aagl";
    tmux = "tmux -2"; # `-2` force assume the terminal supports 256 colors
    # Run `TERM=xterm-ghostty command ssh` if the remote machine has the
    # corresponding terminfo installed
    ssh = "TERM=xterm-256color ssh";
    sshot = "ssh -o 'ConnectTimeout=10' -o 'IdentitiesOnly=no' -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no'"; # One-time SSH session
    sshstop = "ssh -O stop"; # Close a persistent SSH session
    status = "systemctl status";
    is-active = "systemctl is-active";
    start = "sudo systemctl start";
    stop = "sudo systemctl stop";
    restart = "sudo systemctl restart";
    tarxz = "tar -I xz -cvf";
    tarxzls = "tar -I xz -tvf";
    tarzst = "tar -I 'zstd -T0' -cvf";
    tarzstls = "tar -I 'zstd -T0' -tvf";
    targz = "tar -I 'nix run nixpkgs#pigz --' -cvf";
    targzls = "tar -I 'nix run nixpkgs#pigz --' -tvf";
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
      in lib.mkAfter ''
        get-ssh-key() {
          # Check if the required key_id argument is provided
          if [[ -z "$1" ]]; then
            echo "Usage: get-ssh-key <pgp_key_id>" >&2
            return 1
          fi

          # Run the core logic in a subshell to contain 'set -e' and the EXIT trap
          (
            set -eufo pipefail

            TMP_KEY=$(mktemp)

            # The EXIT trap will trigger exactly when this subshell finishes or fails
            trap 'rm -f "$TMP_KEY"' EXIT

            # Export the key securely to the temporary file
            gpg --quiet --batch --yes -ao "$TMP_KEY" --export-secret-subkeys "$1"

            # Pass the temp file path, a newline, and the index '1' to pgp2ssh
            printf "%s\n1\n" "$TMP_KEY" \
              | pgp2ssh 2>&1 \
              | awk 'BEGIN { A=0; } /BEGIN OPENSSH PRIVATE KEY/ { A=1; } { if (A==1) { print; } }'
          )
        }
        # Export my GPG primary keys and subkeys
        export-gpg-keys() (
          set -eufo pipefail

          OUTPUT_DIR=$(zoxide query --list Secrets | grep --max-count=1 'Secrets' || echo ${config.home.homeDirectory}/Secrets)
          KEYS=(
            "primary:75DB252683B07650"
            "auth:30973F79B17F9ED3"
            "enc:940B76AB99D87247"
            "sig:FC4881A7361DF34E"
          )

          for pair in "''${KEYS[@]}"; do
            local key="''${pair%%:*}"
            local key_id="''${pair##*:}"
            if gpg --armor --export-secret-keys $key_id! > $OUTPUT_DIR/sudaku233@outlook.com.''${key}.priv.asc; then
              echo "Key: $key, ID: $key_id exported successful!"
            else
              echo "Key: $key, ID: $key_id export failed!"
            fi
          done
        )
        export PATH="$PATH:${local_bin}:${go_bin}:${rust_bin}"
      '';
    };
    eza = { # A modern replacement for ‘ls’, useful in bash/zsh prompt, but not in nushell
      enable = if pkgs.stdenv.hostPlatform.isRiscV64 then false else true;
      git = true;
      icons = "auto";
    };
    bat = { # a cat-like with syntax highlighting and Git integration.
      enable = true;
      config.pager = "less -FR";
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
    # z foo             # cd into highest ranked directory matching foo
    # z foo bar         # cd into highest ranked directory matching foo and bar
    # z foo /           # cd into a subdirectory starting with foo
    #
    # z ~/foo           # z also works like a regular cd command
    # z foo/            # cd into relative path
    # z ..              # cd one level up
    # z -               # cd into previous directory
    #
    # zi foo            # cd with interactive selection (using fzf)
    #
    # z foo<SPACE><TAB> # show interactive completions (zoxide v0.8.0+, bash 4.4+/fish/zsh only)
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
