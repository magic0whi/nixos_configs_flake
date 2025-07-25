# This file is not imported into your NixOS configuration. It is only used for the agenix CLI.
# agenix use the public keys defined in this file to encrypt the secrets.
# and users can decrypt the secrets by any of the corresponding private keys.
let
  # A key for recovery purpose, generated by `ssh-keygen -t ed25519 -a 256 -C "ryan@agenix-recovery"` with a strong passphrase and keeped it offline in a safe place.
  recovery_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIClFmzSjsfApgmBto1ejpI7trvfHKzECHAVIFh1hSKGR lollipop.studio.cn@gmail.com";
  # For opengpg, run:
  # gpg --list-secret-keys --keyid-format short
  # gpg --export-ssh-key <subkey_with_[A]>\!
  opengpg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBAm5d2IeApyfv8zLb7IMpex7wVHkCV86ztON7HFTkn openpgp:0xB17F9ED3";
  # Get system's ssh public key by command:
  #    cat /etc/ssh/ssh_host_ed25519_key.pub
  # If you do not have this file, you can generate all the host keys by command:
  #    sudo ssh-keygen -A
  # idol_ai = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINHZtzeaQyXwuRMLzoOAuTu8P9bu5yc5MBwo5LI3iWBV root@ai";
  # harmonica = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINT7Pgy/Yl+t6UkHp5+8zfeyJqeJ8EndyR1Vjf/XBe5f root@harmonica";
  # fern = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMokXUYcUy7tysH4tRR6pevFjyOP4cXMjpBSgBZggm9X root@fern";

  machines = [
    recovery_key
    opengpg
    # idol_ai
    # harmonica
    # fern
  ];
in {
  # To see & edit encrypted file, run:
  # agenix -e config.json.age -i <(pgp2ssh <<< <(gpg -ao - --export-secret-subkeys subkey_with_[A]\!) <<< 1 2>&1 | awk 'BEGIN { A=0; S=0; } /BEGIN OPENSSH PRIVATE KEY/ { A=1; } { if (A==1) { print; } }')
  "config.json.age".publicKeys = machines;
  "proteus.smb.age".publicKeys = machines;
  "syncthing_Proteus-MBP14M4P.key.pem.age".publicKeys = machines;
  "syncthing_proteus-nuc.key.pem.age".publicKeys = machines;
}
