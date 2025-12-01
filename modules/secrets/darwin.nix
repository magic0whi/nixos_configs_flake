_: {
  launchd.daemons."activate-agenix".serviceConfig = { # Enable logs for debugging
    StandardErrorPath = "/Library/Logs/org.nixos.activate-agenix.stderr.log";
    StandardOutPath = "/Library/Logs/org.nixos.activate-agenix.stdout.log";
  };
}
