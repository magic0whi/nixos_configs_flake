{agenix, config, mylib, myvars, pkgs, ...}: let
  custom_files_dir = mylib.relative_to_root "custom_files";
in {
  home.packages = [pkgs.nvtopPackages.intel];
  programs.ssh = {
    enable = true;
    forwardAgent = true; # Allow to securely use local SSH agent toauthenticate
    # on the remote machine. It has the same effect as adding cli option `ssh -A user@host`
    addKeysToAgent = "yes";  # A private key that is used during authentication
    # will be added to ssh-agent if it is running
  };
  programs.gpg.publicKeys = [ # https://www.gnupg.org/gph/en/manual/x334.html
    {
      source = mylib.relative_to_root "custom_files/proteus.pub.asc";
      trust = 5; # ultimate trust, my own keys
    }
  ];
}
