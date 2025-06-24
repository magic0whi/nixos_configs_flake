{agenix, config, mylib, myvars, ...}: let
  custom_files_dir = mylib.relative_to_root "custom_files";
in {
  programs.mpv.profiles.common = {
    vulkan-device = "Apple M4 Pro";
    ao = "avfoundation";
  };
  ## START secrets.nix
  imports = [agenix.homeManagerModules.default];
  age.identityPaths = ["${config.home.homeDirectory}/sync-work/3keys/private/legacy/proteus_ed25519.key"];
  age.secrets = let
    noaccess = {mode = "0000";};
    high_security = {mode = "0500";};
  in {
    "syncthing_Proteus-MBP14M4P.key.pem" = {file = "${custom_files_dir}/syncthing_Proteus-MBP14M4P.key.pem.age";} // high_security;
  };
  ## END secrets.nix
  launchd.agents.syncthing.config = {
    StandardErrorPath = "/Users/${myvars.username}/Library/Logs/syncthing/stderr";
    StandardOutPath = "/Users/${myvars.username}/Library/Logs/syncthing/stdout";
  };
  services.syncthing = {
    key = config.age.secrets."syncthing_Proteus-MBP14M4P.key.pem".path;
    cert = "${custom_files_dir}/syncthing_Proteus-MBP14M4P.crt.pem";
    settings = {
      devices = {
        "LGE-AN00" = { id = "T2V6DJB-243NJGD-5B63LUP-DSLNFBD-U72KGD2-AZVTIHL-HEUMBTI-HAVD7A2"; };
        "M2011K2C" = { id = "M3HVW3S-OC32FV6-AHQ7JVU-KY7DQQ4-VF57UYZ-NCJCTU4-M2OXF4H-CY3HYAS"; };
        "PROTEUSDESKTOP" = { id = "CLNAXLW-B2DBSV3-PDT246K-4CZQWGP-EE5MSB4-RUFYUKD-4ALXDXT-HZU3WAN"; };
        "PROTEUSNOTEBOOK-WIN" = { id = "QAQHY4R-7KAQYI6-3WLUHMF-Y4LG5LR-XJMDYTF-3LUIOX3-VO33BCP-RBDM2A6"; };
      };
      folders = {
        "sync-work" = {
          path = "~/sync-work";
          devices = [ "LGE-AN00" "M2011K2C" "PROTEUSDESKTOP" "PROTEUSNOTEBOOK-WIN" ];
        };
      };
    };
  };
}
