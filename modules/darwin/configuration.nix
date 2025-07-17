# NOTE: Some options are not supported by nix-darwin directly, manually set them:
#   1. To avoid conflicts with neovim, disable ctrl + up/down/left/right to switch spaces in:
#     [System Preferences] -> [Keyboard] -> [Keyboard Shortcuts] -> [Mission Control]
#   2. Disable use Caps Lock as 中/英 switch in:
#     [System Preferences] -> [Keyboard] -> [Input Sources] -> [Edit] -> [Use 中/英 key to switch ] -> [Disable]
{lib, ...}: with lib; {
  time.timeZone = mkDefault "Asia/Hong_Kong"; # Please set 'Set time zone automatically using your current location' to false in 'System Settings'
  system = {
    defaults = { ## NOTE: https://github.com/nix-darwin/nix-darwin/issues/1207#issuecomment-2510402916
      CustomUserPreferences = { # customize settings that not supported by nix-darwin directly
        # Incomplete list of macOS `defaults` commands :
        #   https://github.com/yannbertrand/macos-defaults
        "com.apple.desktopservices" = { # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
      };
      menuExtraClock.Show24Hour = mkDefault true;
      menuExtraClock.ShowSeconds = mkDefault true;
      menuExtraClock.ShowAMPM = mkDefault false;
      dock = {
        autohide = mkDefault true;
        show-recents = mkDefault false; # do not show recent apps in dock
        mru-spaces = mkDefault false; # do not automatically rearrange spaces based on most recent use
        expose-group-apps = mkDefault true; # Group windows by apps in Mission Control
        # Hot corner action for corners, see https://github.com/nix-darwin/nix-darwin/blob/44a7d0e687a87b73facfe94fba78d323a6686a90/modules/system/defaults/dock.nix#L308
        wvous-tl-corner = mkDefault 2; # top-left - Mission Control
        wvous-tr-corner = mkDefault 4; # top-right - Desktop
        wvous-bl-corner = mkDefault 3; # bottom-left - Application Windows
        wvous-br-corner = mkDefault 11; # bottom-right - Launchpad
      };
      trackpad = {
        Clicking = mkDefault true; # Tap (without vibration feedback) to click, may need restart to take affect
        TrackpadRightClick = mkDefault true; # Two finger right click
        TrackpadThreeFingerDrag = mkDefault true; # Three finger drag
      };
      finder = {
        _FXShowPosixPathInTitle = mkDefault true;
        _FXSortFoldersFirst = mkDefault true;
        AppleShowAllExtensions = mkDefault true;
        AppleShowAllFiles = mkDefault true; # Show hidden files
        FXDefaultSearchScope = mkDefault "SCcf"; # Search scope to current folder
        FXEnableExtensionChangeWarning = mkDefault false;
        FXPreferredViewStyle = mkDefault "Nlsv"; # List view
        NewWindowTarget = mkDefault "Home"; # Change default folder shown to home
        QuitMenuItem = mkDefault true; # Allow quitting of the Finder
        ShowMountedServersOnDesktop = mkDefault true;
        ShowPathbar = mkDefault true; # Show path breadcrumbs in info bar
        ShowStatusBar = mkDefault true; # show status bar
      };
      NSGlobalDomain = {
        AppleICUForce24HourTime = mkDefault true; # Use 24-hour instead of based on region settings.
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
