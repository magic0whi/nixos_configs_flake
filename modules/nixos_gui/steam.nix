{pkgs, config, ...}: {
  programs.steam = {
    enable = pkgs.stdenv.isx86_64;
    # This also enables programs.gamescope.enable
    gamescopeSession.enable = config.programs.steam.enable;
    # Use `steam-run` to run steam FHS, e.g. `steam-run gamescope`
    # extraPackages = with pkgs; [ # Steam only packages
      # gamescope
    # ];
  };
}
