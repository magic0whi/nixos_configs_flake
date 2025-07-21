{pkgs, lib, ...}: with lib; {
  home.shellAliases = {"mpv" = mkDefault "mpv --player-operation-mode=pseudo-gui";};
  home.activation.set_mpv_associations = mkDefault (hm.dag.entryAfter ["writeBoundary"] ''
    # Set UTIs
    ${getExe' pkgs.duti "duti"} -s io.mpv public.movie viewer
    # Set file extensions
    ${getExe' pkgs.duti "duti"} -s io.mpv .mkv viewer
    ${getExe' pkgs.duti "duti"} -s io.mpv .mp4 viewer
  '');
  programs.mpv = with pkgs; {
    enable = mkDefault true;
    package = mkDefault pkgs.mpv-unwrapped; # https://github.com/NixOS/nixpkgs/issues/356860
    defaultProfiles = ["common" "gpu-hq"];
    config = {
      # log-file = "${config.xdg.cacheHome}";

      hwdec-codecs = mkDefault "all"; # Allowed all codecs, see 'mpv --vd=help'
      # vd-lavc-dr = true; # Enable direct rendering, the video will be decoded directly to GPU video memory (or staging buffers). Currently this enables it on AMD or NVIDIA if using OpenGL or unconditionally if using Vulkan. Using video filters of any kind that write to the image data (or output newly allocated frames) will silently disable the DR code path.
      # opengl-pbo = true;

      # audio-exclusive = true; # Let MPV exclusive audio device, will leave other programs have no sound
      # audio-channels = "stereo"; # Try to set 'stereo' to force dual-channel if so audio channels don't pplay properly.
      # audio-normalize-downmix = true; # If you feel that the bgm is too loud and the character voices are small when multiple audio tracks are downmixed to dual-channel, try this. https://github.com/mpv-player/mpv/issues/6563

      save-position-on-quit = mkDefault true; # Save position of last playback, cannot coexist with SVP
      # watch-later-dir = "${config.xdg.stateHome}/mpv/watch_later"; # The directory in which to store the "watch later" temporary files.
      keep-open = mkDefault true; # Do not terminate when playing or seeking beyond the end of the file
      # ontop = true; # Makes the player window stay on top of other windows.

      video-sync = mkDefault "display-resample"; # Resample audio to match the video
      video-sync-max-video-change = mkDefault 5; # Maximum speed difference in percent that is applied to video with '--video-sync=display-*'
      interpolation = mkDefault true; # Reduce stuttering caused by mismatches in the video fps and display refresh rate (aka. judder). Requires '--video-sync=display-*'. 2x memory usage
      # tscale = "mitchell"; # The filter used for interpolating the temporal axis (frames). Requires --interpolation=yes. The default is 'oversample'. Overall, 'mitchell' is smoother (certainly not good as SVP) but blurring, while 'oversample' has no blurring but not smooth (basically restore the 24 fps alike). Choose according to your own needs
      # dither = "error-diffusion"; # default: fruit. The error-diffusion algorithm requires large amount of shared memory to run
      dither-size-fruit = mkDefault 7; # Set the size of the dither matrix (default: 6). Used in --dither=fruit mode only
      temporal-dither = mkDefault true;

      # Color correction
      # icc-profile="${config.home.homeDirectory}/sync_work/TPLCD_8AAE_AdobeRGB.icm";
      icc-profile-auto = mkDefault true;
      # icc-3dlut-size=256x256x256 # Startup will slightly slow, and will increase RAM usage ~500MiB

      audio-file-auto = mkDefault "fuzzy"; # Load all audio files containing the media filename
      # audio-file-paths = "audio";
      alang = mkDefault "eng,en"; # Specify a prioritized list of audio languages to use, as IETF language tags

      sub-auto = mkDefault "fuzzy"; # Load all subs containing the media filename
      sub-file-paths = mkDefault "sub:subtitles"; # mpv will searches for subtitle files in these directories:
        # /path/to/video/
        # /path/to/video/sub/
        # /path/to/video/subtitles/
        # the sub configuration subdirectory (usually ~/.config/mpv/sub/)
      slang= mkDefault "chi,zh-CN,sc,chs"; # Equivalent to --alang, for subtitle tracks
      # sub-ass-use-video-data = "none"; # Whether the subtitle aspects the video ratio, 3D rotations and blurs

      screenshot-format = mkDefault "avif"; # AV1 Image File Format
    };
    profiles = { # NOTE: Conditions are executed as Lua code
      "HDR_or_21:9" = {
        profile-cond = mkDefault "p[\"video-params/primaries\"]==\"bt.2020\" or p[\"video-params/aspect\"]>=2.0";
        blend-subtitles = mkDefault false;
        sub-ass-force-margins = mkDefault true; # Enables placing toptitles and subtitles in black borders when they are available. Default: no
      };
      "SDR_and_16:9" = {
        profile-cond = mkDefault "p[\"video-params/primaries\"]~=\"bt.2020\" and p[\"video-params/aspect\"]<2.0";
        blend-subtitles = mkDefault true; # Blend subtitles directly onto upscaled video frames, before interpolation and/or color management (default: no). Enabling this causes subtitles to be affected by --icc-profile, --target-prim, --target-trc, --interpolation, --gamma-factor and --glsl-shaders. It also increases subtitle performance when using --interpolation. The downside of enabling this is that it restricts subtitles to the visible portion of the video, so you can't have subtitles exist in the black margins below a video
        sub-ass-force-margins = mkDefault false;
      };
      common = { # Create a profile based on gpu-hq and linux
        profile = mkDefault "gpu-hq";
        fbo-format = mkDefault "rgba32f";
        vo = mkDefault "gpu-next";
        # vo = "dmabuf-wayland";
        gpu-api = mkDefault "vulkan";
        vulkan-device = mkDefault ""; # See 'mpv --vulkan-device=help'
        hwdec = mkDefault "auto";
        ao = mkDefault "pipewire";
      };
      Low = { # 1080 * 1.414213 / 4 = 381.8
        "\#\nglsl-shaders-clr\n\#" = mkForce "Currently mpv.nix doesn't support hm.dag, see https://github.com/nix-community/home-manager/blob/master/modules/programs/mpv.nix";
        profile-desc = mkDefault "Applies for 240p/360p, enable scalling twice to achieve 4x";
        profile-cond = mkDefault "p[\"video-params/w\"]<=678 and p[\"video-params/h\"]<=381";
        profile = mkDefault "common";
        glsl-shaders-append = ["${mpv-shim-default-shaders}/share/mpv-shim-default-shaders/shaders/KrigBilateral.glsl" "${mpv-shim-default-shaders}/share/mpv-shim-default-shaders/shaders/nnedi3-nns32-win8x6.hook" "${mpv-shim-default-shaders}/share/mpv-shim-default-shaders/shaders/nnedi3-nns32-win8x6.hook"];
      };
      SD = { # 1080 / 16 * 9 = 607.5
        "\#\nglsl-shaders-clr\n\#" = mkForce "Placeholder";
        profile-desc = mkDefault "Applies for 480p/576p";
        profile-cond = mkDefault "(p[\"video-params/w\"]<1080 and p[\"video-params/h\"]<608) and (p[\"video-params/w\"]>678 or p[\"video-params/h\"]>381)";
        profile = mkDefault "common";
        glsl-shaders-append = ["${mpv-shim-default-shaders}/share/mpv-shim-default-shaders/shaders/KrigBilateral.glsl" "${mpv-shim-default-shaders}/share/mpv-shim-default-shaders/shaders/nnedi3-nns64-win8x6.hook"];
      };
      HD30 = { # 1080 * 1.414213 / 2 = 763.7
        "\#\nglsl-shaders-clr\n\#" = mkForce "Placeholder";
        profile-desc = mkDefault "Applies for 640p/720p 30fps";
        profile-cond = mkDefault "(p[\"video-params/w\"]<1358 and p[\"video-params/h\"]<764) and (p[\"video-params/w\"]>=1080 or p[\"video-params/h\"]>=608) and p[\"estimated-vf-fps\"]<31";
        profile = mkDefault "common";
        glsl-shaders-append = ["${mpv-shim-default-shaders}/share/mpv-shim-default-shaders/shaders/KrigBilateral.glsl" "${mpv-shim-default-shaders}/share/mpv-shim-default-shaders/shaders/nnedi3-nns32-win8x6.hook"];
      };
      HD60 = {
        "\#\nglsl-shaders-clr\n\#" = mkForce "Placeholder";
        profile-desc = mkDefault "Applies for 640p/720p 60fps";
        profile-cond = mkDefault "(p[\"video-params/w\"]<1358 and p[\"video-params/h\"]<764) and (p[\"video-params/w\"]>=1080 or p[\"video-params/h\"]>=608) and p[\"estimated-vf-fps\"]>=31";
        profile = mkDefault "common";
        glsl-shaders-append = ["${mpv-shim-default-shaders}/share/mpv-shim-default-shaders/shaders/KrigBilateral.glsl" "${mpv-shim-default-shaders}/share/mpv-shim-default-shaders/shaders/SSimSuperRes.glsl"]; # For SSimSuperRes it is recommend to turn off sigmoid-upscaling.
        sigmoid-upscaling = mkDefault false; # When upscaling, use a sigmoidal color transform to avoid emphasizing ringing artifact. Default to yes in profile 'gpu-hq'
      };
      KrigBilateral = {
        "\#\nglsl-shaders-clr\n\#" = mkForce "Placeholder";
        profile = mkDefault "common";
        glsl-shaders-append = mkDefault "${mpv-shim-default-shaders}/share/mpv-shim-default-shaders/shaders/KrigBilateral.glsl";
      };
      FHD = {
        "\#\nglsl-shaders-clr\n\#" = mkForce "Placeholder";
        profile-desc = mkDefault "Applies for 1080p";
        profile-cond = mkDefault "(p[\"video-params/w\"]<=1920 and p[\"video-params/h\"]<=1080) and (p[\"video-params/w\"]>=1358 or p[\"video-params/h\"]>=764)";
        profile = mkDefault "KrigBilateral";
      };
      UHD30 = {
        "\#\nglsl-shaders-clr\n\#" = mkForce "Placeholder";
        profile-desc = mkDefault "4k 30fps: use SSIM to downscale";
        profile-cond = mkDefault "(p[\"video-params/w\"]>2560 or p[\"video-params/h\"]>1440) and p[\"estimated-vf-fps\"]<31";
        profile = mkDefault "common";
        glsl-shaders-append = mkDefault "${mpv-shim-default-shaders}/share/mpv-shim-default-shaders/shaders/SSimDownscaler.glsl"; # SSimDownscaler requires turn off linear-dewnscaling
        linear-downscaling = mkDefault false; # Scale in linear light when downscaling. It should only be used with a --fbo-format that has at least 16 bit precision. This option has no effect on HDR content. Default to yes in profile 'gpu-hq'
      };
      UHD60 = {
        "\#\nglsl-shaders-clr\n\#" = mkForce "Placeholder";
        profile-desc = mkDefault "4k high fps: use w.o. any glsl-shaders";
        profile-cond = mkDefault "(p[\"video-params/w\"]>1920 or p[\"video-params/h\"]>1080) and p[\"estimated-vf-fps\"]>=31";
        profile = mkDefault "common";
        # If playing 4k videos with a 1080p monitor, consider try https://gist.github.com/bjin/15f307e7a1bdb55842bbb663ee1950ed
        # glsl-shaders-append = "~~/shaders/acme-0.5x.hook";
        fbo-format = mkDefault "auto"; # Doesn't need chroma upscaling anymore. e.g. with a 1080p monitor mpv will do chroma conversion with precision of 1080p level instead of 2160p level
      };
    };
  };
}
