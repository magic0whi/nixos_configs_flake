{myvars, config, lib, pkgs, ...}: {
  age.secrets."paperless.env" = {
    file = "${myvars.secrets_dir}/paperless.env.age"; mode = "0400"; owner = config.services.paperless.user;
  };
  # As of 2026-05-01, paperless.nix still hardcoded group to be same with uesr
  services.paperless = {
    domain = "paperless.${myvars.domain}";
    enable = true;
    settings = {
      PAPERLESS_DBENGINE = "postgresql";
      PAPERLESS_DBHOST = "postgresql.${myvars.domain}";
      PAPERLESS_DBSSLMODE = "require";
      PAPERLESS_DBNAME = config.services.paperless.user;
      PAPERLESS_DBUSER = config.services.paperless.user;

      # https://tesseract-ocr.github.io/tessdoc/Data-Files-in-different-versions.html
      PAPERLESS_OCR_LANGUAGES = "chi-sim chi-tra";
      PAPERLESS_OCR_LANGUAGE = "chi_sim+chi_tra+eng";
      # https://dateparser.readthedocs.io/en/latest/supported_locales.html
      PAPERLESS_DATE_PARSER_LANGUAGES = "en+zh+zh-Hant";

      PAPERLESS_ADMIN_USER = myvars.username;
      PAPERLESS_USE_X_FORWARD_HOST = true;
      PAPERLESS_USE_X_FORWARD_PORT = true;

      APERLESS_WEBSERVER_WORKERS = 16;
      PAPERLESS_WORKER_TIMEOUT = 300; # Default 1800 seconds (30min) is too long
      PAPERLESS_FILENAME_FORMAT = "{{ created_year }}/{{ correspondent }}/{{ document_type }}/{{ title }}";
    };
    environmentFile = config.age.secrets."paperless.env".path;
    # dataDir = "/srv/paperless";
    exporter.enable = true;
    exporter.directory = "/srv/Backups/paperless-export";
    exporter.settings.no-archive = true;
    exporter.settings.no-thumbnail = true;
  };
  systemd.tmpfiles.settings = let cfg = config.services.paperless.exporter; in lib.mkIf cfg.enable {
    "10-paperless-exporter-change-group".${cfg.directory}.z = {mode = "2750"; group = "storage";};
  };
  systemd.services = let cfg = config.services.paperless.exporter;
  in lib.mkIf cfg.enable {paperless-exporter.serviceConfig = {
    # Type=oneshot forces systemd to wait until the paperless-exporter-start script completely finishes (which spawns
    # python to export the PDFs to a temporary folder, then atomically renames it to `cfg.exporter.directory`).
    # If this is Type=simple (the default), systemd will run ExecStartPost instantly, before the PDFs are generated,
    # causing them to be owned by paperless:paperless.
    Type = "oneshot";
    ExecStartPost = ["+${pkgs.coreutils}/bin/chmod -R g+r ${cfg.directory}"];
  };};
}
