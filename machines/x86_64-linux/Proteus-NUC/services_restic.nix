# - To initialize the repository (one-time): restic-<Hostname> init
# - To check backup status: restic-<Hostname> snapshots
# - To retrieve latest snapshots:
#   restic-<Hostname> latest --target /tmp/restic-restore
#   restic-<Hostname> <Snapshot ID> --target /tmp/restic-restore
{
  config,
  myvars,
  ...
}: {
  sops = let
    sopsFile = "${myvars.secrets_dir}/common.sops.yaml";
    restartUnits = ["restic-backups-${config.networking.hostName}.service"];
  in {
    # Restic repository encryption password
    secrets = {
      restic_password = {
        inherit sopsFile restartUnits;
        owner = config.services.restic.backups.${config.networking.hostName}.user;
      };
      restic_aws_secret_access_key = {inherit sopsFile restartUnits;};
    };
    templates."restic.env" = {
      inherit restartUnits;
      content = ''
        AWS_ACCESS_KEY_ID=GKa80ba5756034df47aadc5b8f
        AWS_SECRET_ACCESS_KEY=${config.sops.placeholder.restic_aws_secret_access_key}
      '';
    };
  };
  systemd.services."restic-backups-${config.networking.hostName}".serviceConfig.EnvironmentFile = config.sops.templates."restic.env".path;
  services.restic.backups.${config.networking.hostName} = {
    user = myvars.username; # Default root, set to primary user to ease the use of `restic-<Hostname>` command
    initialize = true; # Create the repository if it doesn’t exist
    # Repository location on Proteus-Desktop
    repository = "s3:s3.${myvars.domain}/backups/${config.networking.hostName}";
    passwordFile = config.sops.secrets.restic_password.path; # Password for restic backup itself
    # An environment file for your storage provider credentials (e.g., AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
    # environmentFile = sops.templates."restic.env".path;

    # Retention policy
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 75"
    ];
    checkOpts = ["--with-cache"]; # Reuse existing cache
    # Run backup + prune + check weekly (Sundays at 3 AM)
    timerConfig = {
      OnCalendar = "*-*-* 03:00:00";
      # RandomizedDelaySec = "30m"; # Jitter
      Persistent = true; # Run immediately if system was off at scheduled time
    };
    # Performance tuning
    extraBackupArgs = ["--limit-upload ${toString (50 * 1024)}"];
    # Limit upload speed to 50 MB/s, unit is KiB/s
    extraOptions = [
      "s3.region=cn-east1-a"
      "read-concurrency=4" # Read concurrency for better throughput on ZFS
    ];
    # Paths to backup
    paths = [
      config.services.paperless.exporter.directory # Paperless
      config.services.immich.mediaLocation # Immich
      config.services.postgresqlBackup.location # Postgresql
      config.services.forgejo.dump.backupDir # Forgejo
      # "/var/lib/tailscale"
    ];
    # Paths to exclude from backup
    exclude = [
      "**/.Trash"
      "**/node_modules"
      # Cache directories
      "*/.cache"
      "*/cache"
      # Temporary / runtime data
      "/srv/immich/upload/thumbs" # Regeneratable thumbnails
      "/srv/immich/upload/encoded-video" # Regeneratable transcodes
    ];
  };
}
