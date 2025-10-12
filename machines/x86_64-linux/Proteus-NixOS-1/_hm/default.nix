{mylib, pkgs, ...}: {
  home.packages = [pkgs.nvtopPackages.intel];
  programs.ssh = {
    enable = true;
    matchBlocks."*" = { # Default values
        # A private key that is used during authentication will be added to
        # ssh-agent if it is running
        addKeysToAgent = "yes";
        # Allow to securely use local SSH agent to authenticate on the remote
        # machine. It has the same effect as adding cli option `ssh -A user@host`
        forwardAgent = true;
    };
  };
  programs.gpg.publicKeys = [ # https://www.gnupg.org/gph/en/manual/x334.html
    {
      source = mylib.relative_to_root "custom_files/proteus.pub.asc";
      trust = 5; # ultimate trust, my own keys
    }
  ];
}
