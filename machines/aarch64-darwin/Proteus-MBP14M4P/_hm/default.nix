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
  xdg.configFile."nix/public.key".source = "${myvars.secrets_dir}/nix-public.key";
  age.secrets = {
    "nix-secret.key" = {
      file = "${myvars.secrets_dir}/nix-secret.key.age";
      mode = "0400";
      path = "${config.xdg.configHome}/nix/secret.key";
    };
    "aws_credentials" = {
      file = "${myvars.secrets_dir}/aws_credentials.age";
      mode = "0400";
      path = "${config.home.homeDirectory}/.aws/credentials";
    };
  };
  ## END nix.nix
}
