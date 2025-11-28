{agenix, config, mylib, myvars, pkgs, ...}: let
  custom_files_dir = mylib.relative_to_root "custom_files";
in {
  launchd.daemons."activate-agenix".serviceConfig = { # Enable logs for debugging
    StandardErrorPath = "/Library/Logs/org.nixos.activate-agenix.stderr.log";
    StandardOutPath = "/Library/Logs/org.nixos.activate-agenix.stdout.log";
  };
  environment.systemPackages = [agenix.packages."${pkgs.stdenv.hostPlatform.system}".default]; # For debugging
  age.identityPaths = ["${config.users.users.${myvars.username}.home}/sync_work/3keys/pgp2ssh.priv.key"];
  age.secrets = let
    noaccess = {mode = "0000"; owner = "root";};
    high_security = {mode = "0500"; owner = "root";};
    user_readable = {mode = "0500"; owner = myvars.username;};
  in {
    "config.json" = {file = "${custom_files_dir}/config.json.age";} // noaccess;
  };
}
