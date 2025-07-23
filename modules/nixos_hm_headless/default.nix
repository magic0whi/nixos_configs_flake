{lib, myvars, mylib, pkgs, ...}: with lib; {
  imports = mylib.scan_path ./.;
  ## START neovim.nix
  # programs.neovim = {
    # enable = mkDefault true;
    # viAlias = mkDefault true;
    # vimAlias = mkDefault true;
  # };
  ## END neovim.nix
  ## START gpg.nix
  programs.gpg = {
    enable = mkDefault true;
    # $GNUPGHOME/trustdb.gpg stores all the trust level you specified in `programs.gpg.publicKeys` option. If set `mutableTrust` to false, the path $GNUPGHOME/trustdb.gpg will be overwritten on each activation. Thus we can only update trsutedb.gpg via home-manager.
    mutableTrust = mkDefault false;
    # $GNUPGHOME/pubring.kbx stores all the public keys you specified in `programs.gpg.publicKeys` option. If set `mutableKeys` to false, the path $GNUPGHOME/pubring.kbx will become an immutable link to the Nix store, denying modifications. Thus we can only update pubring.kbx via home-manager
    mutableKeys = mkDefault false;
    settings = { # This configuration is based on the tutorial https://blog.eleven-labs.com/en/openpgp-almost-perfect-key-pair-part-1, it allows for a robust setup
      no-greeting = mkDefault true; # Get rid of the copyright notice
      no-emit-version = mkDefault true; # Disable inclusion of the version string in ASCII armored output
      no-comments = mkOverride 999 false; # Do not write comment packets
      export-options = mkDefault "export-minimal"; # Export the smallest key possible. This removes all signatures except the most recent self-signature on each user ID
      keyid-format = mkDefault "0xlong"; # Display long key IDs
      with-fingerprint = mkDefault true; # List all keys (or the specified ones) along with their fingerprints
      list-options = mkDefault "show-uid-validity"; # Display the calculated validity of user IDs during key listings
      verify-options = mkOverride 999 "show-uid-validity show-keyserver-urls";
      personal-cipher-preferences = mkOverride 999 "AES256"; # Select the strongest cipher
      personal-digest-preferences = mkOverride 999 "SHA512"; # Select the strongest digest
      default-preference-list = mkOverride 999 "SHA512 SHA384 SHA256 RIPEMD160 AES256 TWOFISH BLOWFISH ZLIB BZIP2 ZIP Uncompressed"; # This preference list is used for new keys and becomes the default for "setpref" in the edit menu

      cipher-algo = mkDefault "AES256"; # Use the strongest cipher algorithm
      digest-algo = mkDefault "SHA512"; # Use the strongest digest algorithm
      cert-digest-algo = mkDefault "SHA512"; # Message digest algorithm used when signing a key
      compress-algo = mkDefault "ZLIB"; # Use RFC-1950 ZLIB compression

      disable-cipher-algo = mkDefault "3DES"; # Disable weak algorithm
      weak-digest = mkDefault "SHA1"; # Treat the specified digest algorithm as weak

      s2k-cipher-algo = mkDefault "AES256"; # The cipher algorithm for symmetric encryption for symmetric encryption with a passphrase
      s2k-digest-algo = mkDefault "SHA512"; # The digest algorithm used to mangle the passphrases for symmetric encryption
      s2k-mode = mkDefault "3"; # Selects how passphrases for symmetric encryption are mangled
      s2k-count = mkDefault "65011712"; # Specify how many times the passphrases mangling for symmetric encryption is repeated
    };
  };
  services.gpg-agent = { # gpg agent with pinentry-qt
    enable = mkDefault true;
    pinentry.package = mkDefault pkgs.pinentry-curses;
    enableSshSupport = mkDefault true;
    defaultCacheTtl = mkDefault (4 * 60 * 60); # 4 hours
    sshKeys = mkDefault myvars.gpg2ssh_keygrip; # Run 'gpg --export-ssh-key gpg-key!' to export public key
  };
  ## END gpg.nix
  systemd.user.services."${myvars.username}".environment.STNODEFAULTFOLDER = lib.mkDefault "true"; # Don't create default ~/Sync folder
  services = {
    udiskie.enable = mkDefault true; # auto mount usb drives
    syncthing.enable = mkDefault true;
    syncthing.tray.enable = mkDefault true;
  };
}
