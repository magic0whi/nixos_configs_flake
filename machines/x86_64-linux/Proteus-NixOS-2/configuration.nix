{myvars, config, pkgs, ...}: {
  time.timeZone = "Europe/Berlin";
  boot.kernelParams = [
    "console=ttyS0,115200"
    "earlyprintk=ttyS0,115200"
    "consoleblank=0"
    "intel_iommu=off"
  ];
  services.syncthing.enable = false;
  ## START sing-box.nix
  age.secrets."sb_Proteus-NixOS-1.json" = {
    file = "${myvars.secrets_dir}/sb_Proteus-NixOS-1.json.age";
    mode = "0000"; owner = "root";
  };
  networking.firewall = {allowedTCPPorts = [443];}; # Reality
  services.sing-box.enable = true;
  services.sing-box.config_file = config.age.secrets."sb_Proteus-NixOS-1.json".path;
  ## END sing-box.nix
  boot.binfmt.emulatedSystems = ["riscv64-linux"]; # Cross compilation
  ## START minio.nix
  age.secrets = {
    "minio/private.key" = {
      file = "${myvars.secrets_dir}/proteus_server.priv.pem.age";
      mode = "0500"; owner = config.systemd.services.minio.serviceConfig.User;
    };
    "minio/minio.env" = {
      file = "${myvars.secrets_dir}/minio.env.age";
      mode = "0500"; owner = config.systemd.services.minio.serviceConfig.User;
    };
  };
  services.minio = {
    enable = true;
    region = "europe-west10-b";
    rootCredentialsFile = config.age.secrets."minio/minio.env".path;
    certificatesDir = "${config.age.secretsDir}/minio";
  };
  # TLS: Copy public.crt to agenix's secret dir
  systemd.services.minio.serviceConfig.ExecStartPre = [
    # `+` prefix let the command run with root user
    "+${pkgs.writeShellScript "link-public-crt" ''
      mkdir -p /run/agenix/minio # Ensure the directory exists
      # Copy the file from Nix store to the runtime path, MinIO requires both
      # private key and public key's file type must same
      cp -f ${myvars.secrets_dir}/proteus_server.pub.pem /run/agenix/minio/public.crt
      chown minio: /run/agenix/minio/public.crt
      chmod 644 /run/agenix/minio/public.crt
    ''}"
  ];
  ## END minio.nix
}
