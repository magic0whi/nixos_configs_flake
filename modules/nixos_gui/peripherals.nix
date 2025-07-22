{pkgs, lib, ...}: {
  # Audio(PipeWire)
  environment.systemPackages = [pkgs.pulseaudio]; # Provides `pactl`, which is required by some apps (e.g. sonic-pi)
  # PipeWire is a new low-level multimedia framework. It aims to offer capture and playback for both audio and video
  # with minimal latency. It support for PulseAudio-, JACK-, ALSA- and GStreamer-based applications. PipeWire has a
  # great bluetooth support, it can be a good alternative to PulseAudio. Ref: https://nixos.wiki/wiki/PipeWire
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa.enable = lib.mkDefault true;
    alsa.support32Bit = lib.mkDefault true;
    pulse.enable = lib.mkDefault true;
    jack.enable = lib.mkDefault true;
    wireplumber.enable = lib.mkDefault true;
  };
  security.rtkit.enable = lib.mkDefault true; # rtkit is optional but recommended
  # Bluetooth
  hardware.bluetooth.enable = lib.mkDefault true;
  services.blueman.enable = lib.mkDefault true;
  # Misc
  services = {
    printing.enable = lib.mkDefault true; # Enable CUPS to print documents.
    geoclue2.enable = lib.mkDefault true; # Enable geolocation services.
    udev.packages = with pkgs; [
      gnome-settings-daemon
      platformio # udev rules for platformio
      openocd # required by paltformio, ref: https://github.com/NixOS/nixpkgs/issues/224895
      android-udev-rules # required by adb
      openfpgaloader
    ];
    keyd = { # A key remapping daemon for linux. Ref: https://github.com/rvaiya/keyd
      enable = lib.mkDefault true;
      keyboards.default.settings = {
        main = {
          # Overloads the capslock key to function as both escape (when tapped) and control (when held)
          capslock = lib.mkDefault "overload(control, esc)";
          esc = lib.mkDefault "capslock";
        };
      };
    };
  };
}
