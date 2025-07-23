{config, lib, myvars, pkgs, ...}: {
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  home.activation.remove_existing_git_config = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f ${config.home.homeDirectory}/.gitconfig
  '';
  home.packages = with pkgs; [
    # Automatically trims your branches whose tracking remote refs are merged or gone
    # It's really useful when you work on a project for a long time.
    git-trim
    gitleaks
  ];
  programs.git = {
    enable = true;
    package = pkgs.emptyDirectory; # Already in `environment.systemPackages`, set to dummy package
    lfs.enable = true; # used by huggingface models
    userName = myvars.userfullname;
    userEmail = myvars.useremail;
    includes = [
      { # Use different email & name for work
        condition = "gitdir:~/work/";
        path = "~/work/.gitconfig";
      }
    ];
    extraConfig = {
      init.defaultBranch = "main";
      trim.bases = "develop,master,main"; # For git-trim
      push.autoSetupRemote = true;
      pull.rebase = true;
      url = {
        "ssh://git@ssh.github.com:443/${myvars.github_username}" = { # Replace https with ssh
          insteadOf = "https://github.com/${myvars.github_username}";
        };
        # "ssh://git@gitlab.com/" = {
        #   insteadOf = "https://gitlab.com/";
        # };
        # "ssh://git@bitbucket.com/" = {
        #   insteadOf = "https://bitbucket.com/";
        # };
      };
    };
    signing = {
      format = "openpgp";
      key = myvars.git_signingkey;
      signByDefault = true;
    };
    delta = { # A syntax-highlighting pager in Rust
      enable = true;
      options = {
        diff-so-fancy = true;
        line-numbers = true;
        true-color = "always";
        # features = ""; # features => named groups of settings, used to keep related settings organized
      };
    };
    aliases = let log_fmt = " --pretty='format:%C(green)%G? %C(yellow)%h%C(auto)%d\\ %s\\ %C(blue)[%cn]%C(reset)'";
    in { # Custom aliases for git
      br = "branch";
      co = "checkout";
      st = "status";
      # Format placeholders:
      # - %C(...): color specification, respecting the auto settings
      # - %G?: Show signature status
      # - %cn: committer name
      # - %d: ref name. e.g. ' (HEAD)' (yes it has a prefix space)
      # - %h: abbreviated commit hash. e.g. 'c4f4c1f'
      # - %s: subject. e.g. 'feat: consolidate configs and enhance shell in NixOS/Darwin'
      ls = "log --graph" + log_fmt;
      ll = "log --graph --numstat" + log_fmt;
      la = "log --graph --all" + log_fmt;
      cm = "commit -sm"; # commit via `git cm <message>`
      ca = "commit -asm"; # commit all changes via `git ca <message>`
      dc = "diff --cached";
      amend = "commit --amend -m"; # amend commit message via `git amend <message>`
      unstage = "reset HEAD --"; # unstage file via `git unstage <file>`
      merged = "branch --merged"; # list merged(into HEAD) branches via `git merged`
      unmerged = "branch --no-merged"; # list unmerged(into HEAD) branches via `git unmerged`
      nonexist = "remote prune origin --dry-run"; # list non-exist(remote) branches via `git nonexist`

      # Delete merged branches except master & dev & staging. `!` indicates it's a shell script, not a git subcommand
      delmerged = ''! git branch --merged | egrep -v "(^\*|main|master|dev|staging)" | xargs git branch -d'';
      delnonexist = "remote prune origin"; # delete non-exist(remote) branches

      # Aliases for submodule
      update = "submodule update --init --recursive";
      foreach = "submodule foreach";
    };
  };
}
