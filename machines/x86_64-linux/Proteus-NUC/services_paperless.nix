{myvars, config, lib, pkgs, ...}: {
  ## START services_paperless.nix
  age.secrets."paperless.env" = {
    file = "${myvars.secrets_dir}/paperless.env.age"; mode = "0400"; owner = config.services.paperless.user;
  };
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
    dataDir = "/srv/paperless";
    exporter.enable = true;
  };
  systemd.services.paperless-exporter.serviceConfig = lib.mkIf config.services.paperless.exporter.enable {
    EnvironmentFile = config.age.secrets."paperless.env".path;
    ExecStartPost = [
      "+${pkgs.coreutils}/bin/chown -R ${myvars.username}:${config.services.paperless.user} ${config.services.paperless.dataDir}/export"
      "+${pkgs.coreutils}/bin/chmod -R u+rwX,g+rwX ${config.services.paperless.dataDir}/export"
    ];
  };
  systemd.tmpfiles.rules = lib.mkIf config.services.paperless.exporter.enable [
    "z '${config.services.paperless.dataDir}/export' 2770 ${myvars.username} ${config.services.paperless.user} - -"
  ];
  ## END services_paperless.nix
}
