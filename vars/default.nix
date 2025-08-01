{lib, ...}: {
  username = "proteus";
  userfullname = "Proteus Qian";
  useremail = "sudaku233@outlook.com";
  nixos_state_version = "25.05";
  darwin_state_version = 6;
  github_username = "magic0whi";
  networking = import ./networking.nix {inherit lib;};
  # generated by `mkpasswd -m scrypt`
  initial_hashed_password = "$7$CU..../....ok6SfTAfNaBUnQ96VKt.Y.$e6xJ04cp782zzn07DNj7PtvteiEbpzKyeWibpkQIXX.";
  # Public Keys that can be used to login to all my PCs, Macbooks, and servers.
  #
  # Since its authority is so large, we must strengthen its security:
  # 1. The corresponding private key must be:
  #    1. Generated locally on every trusted client via:
  #      ```bash
  #      # KDF: bcrypt with 256 rounds, takes 2s on Apple M2):
  #      # Passphrase: digits + letters + symbols, 12+ chars
  #      ssh-keygen -t ed25519 -a 256 -C "ryan@xxx" -f ~/.ssh/xxx`
  #      ```
  #    2. Never leave the device and never sent over the network.
  # 2. Or just use hardware security keys like Yubikey/CanoKey.
  ssh_authorized_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIClFmzSjsfApgmBto1ejpI7trvfHKzECHAVIFh1hSKGR lollipop.studio.cn@gmail.com"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBAm5d2IeApyfv8zLb7IMpex7wVHkCV86ztON7HFTkn openpgp:0xB17F9ED3"
  ];
  # Use an [A]uthenticate subkey, run `gpg --list-secret-keys --with-keygrip` to show its keygrip
  git_signingkey = "73EDF7A727CC3B5F329863DBFC4881A7361DF34E";
  gpg2ssh_keygrip = [
    "94BDB192359497927D5AA4AC76D238BA1BFEFE57"
  ];
  catppuccin_variant = "mocha";
  catppuccin_accent = "pink";
}
