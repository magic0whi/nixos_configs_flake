{mylib, pkgs, myvars, config, ...}: {
  imports = mylib.scan_path ./.;
  home.packages = with pkgs; [
    xmrig # Heating
    chezmoi
  ];
  programs = {
    aerospace.settings.workspace-to-monitor-force-assignment = {
      "7" = ["C340SCA"];
      "8" = ["C340SCA"];
      "9" = ["RTK UHD HDR"];
      "0" = ["RTK UHD HDR"];
    };
    mpv.profiles.common = {
      vulkan-device = "Apple M4 Pro";
      ao = "avfoundation";
    };
  };
  ## BEGIN nix.nix
  xdg.configFile."nix/public.key".source = "${myvars.secrets_dir}/nix_public.key";
  sops.secrets = {
    "nix_secret.key" = {
      sopsFile = "${myvars.secrets_dir}/nix_secret.key.sops";
      format = "binary";
      path = "${config.xdg.configHome}/nix/secret.key";
    };
    aws_secret_access_key.sopsFile = "${myvars.secrets_dir}/aws_credentials.sops.yaml";
  };
  sops.templates."aws_credentials" = {
    content = ''
      [nixbuilder]
      aws_access_key_id=nixbuilder
      aws_secret_access_key=${config.sops.placeholder.aws_secret_access_key}
    '';
    path = "${config.home.homeDirectory}/.aws/credentials";
  };
  ## END nix.nix
}
