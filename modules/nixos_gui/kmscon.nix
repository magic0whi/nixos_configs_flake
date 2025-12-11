{pkgs, ...}: {
  services.kmscon = { # https://wiki.archlinux.org/title/KMSCON
    # Use kmscon as the virtual console instead of gettys. kmscon is a
    # kms/dri-based userspace virtual terminal implementation. It supports a
    # richer feature set than the standard linux console VT, including full
    # unicode support, and when the video card supports drm should be much faster.
    # NOTE: This will make `hardware.graphics.enable = true`, which installs
    # mesa packages (~985.48MiB as 12/02/25)
    enable = true;
    fonts = [{name = "Iosevka Nerd Font Mono"; package = pkgs.nerd-fonts.iosevka;}];
    hwRender = true; # Whether to use 3D hardware acceleration to render the console.
    extraOptions = "--term xterm-256color";
    extraConfig = ''font-size=12'';
  };
}
