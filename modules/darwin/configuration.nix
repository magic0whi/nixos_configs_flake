###################################################################################
#
#  macOS's System configuration
#
#  All the configuration options are documented here:
#    https://daiderd.com/nix-darwin/manual/index.html#sec-options
#  Incomplete list of macOS `defaults` commands :
#    https://github.com/yannbertrand/macos-defaults
#
#
# NOTE: Some options are not supported by nix-darwin directly, manually set them:
#   1. To avoid conflicts with neovim, disable ctrl + up/down/left/right to switch spaces in:
#     [System Preferences] -> [Keyboard] -> [Keyboard Shortcuts] -> [Mission Control]
#   2. Disable use Caps Lock as 中/英 switch in:
#     [System Preferences] -> [Keyboard] -> [Input Sources] -> [Edit] -> [Use 中/英 key to switch ] -> [Disable]
###################################################################################
{lib, ...}: with lib; {
  time.timeZone = mkDefault "Asia/Hong_Kong";
  system = {
    defaults = { ## NOTE: https://github.com/nix-darwin/nix-darwin/issues/1207#issuecomment-2510402916
      menuExtraClock.Show24Hour = mkDefault true;
      menuExtraClock.ShowSeconds = mkDefault true;
      dock = {
        autohide = mkDefault true;
        show-recents = mkDefault false; # do not show recent apps in dock
        mru-spaces = mkDefault false; # do not automatically rearrange spaces based on most recent use
        expose-group-apps = mkDefault true; # Group windows by apps in Mission Control
        # Hot corner action for corners, see https://github.com/nix-darwin/nix-darwin/blob/44a7d0e687a87b73facfe94fba78d323a6686a90/modules/system/defaults/dock.nix#L308
        wvous-tl-corner = mkDefault 2; # top-left - Mission Control
        wvous-tr-corner = mkDefault 4; # top-right - Desktop
        wvous-bl-corner = mkDefault 3; # bottom-left - Application Windows
        wvous-br-corner = mkDefault 13; # bottom-right - Lock Screen
      };
      trackpad = {
        Clicking = mkDefault true; # Tap (without vibration feedback) to click, may need restart to take affect
        TrackpadRightClick = mkDefault true; # Two finger right click
        TrackpadThreeFingerDrag = mkDefault true; # Three finger drag
      };
      finder = {
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXDefaultSearchScope = "SCcf"; # Search scope to current folder
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv"; # List view
        QuitMenuItem = true; # Allow quitting of the Finder
        ShowMountedServersOnDesktop = true;
        ShowPathbar = true; # Show path breadcrumbs in finder windows
        ShowStatusBar = true; # show status bar
      };
      NSGlobalDomain = {
        AppleKeyboardUIMode = mkDefault 3; # Configures the keyboard control behavior. Mode 3 enables full keyboard control
        NSAutomaticQuoteSubstitutionEnabled = mkDefault false; # Disable auto quote substitution
      };
    };
    keyboard = {
      enableKeyMapping = mkDefault true;
      remapCapsLockToEscape = mkDefault true; # Remap caps lock to escape, useful for vim users
      userKeyMapping = [
        { # Remap escape to caps lock
          HIDKeyboardModifierMappingSrc = 30064771113;
          HIDKeyboardModifierMappingDst = 30064771129;
        }
      ];
    };
  };
}
