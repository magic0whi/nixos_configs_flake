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
    enable = lib.mkDefault true;
    package = lib.mkDefault pkgs.emptyDirectory; # Already in `environment.systemPackages`, set to dummy package
    lfs.enable = lib.mkDefault true; # used by huggingface models
    userName = lib.mkDefault myvars.userfullname;
    userEmail = lib.mkDefault myvars.useremail;
    includes = [
      { # Use different email & name for work
        condition = "gitdir:~/work/";
        path = "~/work/.gitconfig";
      }
    ];
    extraConfig = {
      init.defaultBranch = lib.mkDefault "main";
      trim.bases = lib.mkDefault "develop,master,main"; # For git-trim
      push.autoSetupRemote = lib.mkDefault true;
      pull.rebase = lib.mkDefault true;
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
      format = lib.mkDefault "openpgp";
      key = lib.mkDefault myvars.git_signingkey;
      signByDefault = lib.mkDefault true;
    };
    delta = { # A syntax-highlighting pager in Rust
      enable = lib.mkDefault true;
      options = {
        diff-so-fancy = lib.mkDefault true;
        line-numbers = lib.mkDefault true;
        true-color = lib.mkDefault "always";
        # features = ""; # features => named groups of settings, used to keep related settings organized
      };
    };
    aliases = let log_fmt = " --pretty='format:%C(green)%G? %C(yellow)%h%C(auto)%d\\ %s\\ %C(blue)[%cn]%C(reset)'";
    in { # Custom aliases for git
      br = lib.mkDefault "branch";
      co = lib.mkDefault "checkout";
      st = lib.mkDefault "status";
      # Format placeholders:
      # - %C(...): color specification, respecting the auto settings
      # - %G?: Show signature status
      # - %cn: committer name
      # - %d: ref name. e.g. ' (HEAD)' (yes it has a prefix space)
      # - %h: abbreviated commit hash. e.g. 'c4f4c1f'
      # - %s: subject. e.g. 'feat: consolidate configs and enhance shell in NixOS/Darwin'
      ls = lib.mkDefault ("log --graph" + log_fmt);
      ll = lib.mkDefault ("log --graph --numstat" + log_fmt);
      la = lib.mkDefault ("log --graph --all" + log_fmt);
      cm = lib.mkDefault "commit -sm"; # commit via `git cm <message>`
      ca = lib.mkDefault "commit -asm"; # commit all changes via `git ca <message>`
      dc = lib.mkDefault "diff --cached";
      amend = lib.mkDefault "commit --amend -m"; # amend commit message via `git amend <message>`
      unstage = lib.mkDefault "reset HEAD --"; # unstage file via `git unstage <file>`
      merged = lib.mkDefault "branch --merged"; # list merged(into HEAD) branches via `git merged`
      unmerged = lib.mkDefault "branch --no-merged"; # list unmerged(into HEAD) branches via `git unmerged`
      nonexist = lib.mkDefault "remote prune origin --dry-run"; # list non-exist(remote) branches via `git nonexist`

      # Delete merged branches except master & dev & staging. `!` indicates it's a shell script, not a git subcommand
      delmerged = lib.mkDefault
        ''! git branch --merged | egrep -v "(^\*|main|master|dev|staging)" | xargs git branch -d'';
      delnonexist = lib.mkDefault "remote prune origin"; # delete non-exist(remote) branches

      # Aliases for submodule
      update = lib.mkDefault "submodule update --init --recursive";
      foreach = lib.mkDefault "submodule foreach";
    };
  };
}
