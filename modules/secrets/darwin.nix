{agenix, config, mylib, myvars, pkgs, ...}: let
  mysecrets = mylib.relative_to_root "custom_files";
in {
  imports = [agenix.nixosModules.default];
  launchd.daemons."activate-agenix".serviceConfig = { # Enable logs for debugging
    StandardErrorPath = "/Library/Logs/org.nixos.activate-agenix.stderr.log";
    StandardOutPath = "/Library/Logs/org.nixos.activate-agenix.stdout.log";
  };
  environment.systemPackages = [agenix.packages."${pkgs.system}".default]; # For debugging
  age.identityPaths = ["/Users/${myvars.username}/sync-work/3keys/private/legacy/proteus_ed25519.key"];
  age.secrets = let
    noaccess = {
      mode = "0000";
      owner = "root";
    };
    high_security = {
      mode = "0500";
      owner = "root";
    };
    user_readable = {
      mode = "0500";
      owner = myvars.username;
    };
  in { # TODO
  };
}
