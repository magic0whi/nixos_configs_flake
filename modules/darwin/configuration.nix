# NOTE: Some options are not supported by nix-darwin directly, manually set them:
#   1. To avoid conflicts with neovim, disable ctrl + up/down/left/right to switch spaces in:
#     [System Preferences] -> [Keyboard] -> [Keyboard Shortcuts] -> [Mission Control]
#   2. Disable use Caps Lock as 中/英 switch in:
#     [System Preferences] -> [Keyboard] -> [Input Sources] -> [Edit] -> [Use 中/英 key to switch ] -> [Disable]
{lib, ...}: {
  system = {
    defaults = { ## NOTE: https://github.com/nix-darwin/nix-darwin/issues/1207#issuecomment-2510402916
      CustomUserPreferences = { # Customize settings that not supported by nix-darwin directly
        # Incomplete list of macOS `defaults` commands: https://github.com/yannbertrand/macos-defaults
        "com.apple.desktopservices" = { # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = lib.mkDefault true;
          DSDontWriteUSBStores = lib.mkDefault true;
        };
      };
      menuExtraClock.Show24Hour = lib.mkDefault true;
      menuExtraClock.ShowSeconds = lib.mkDefault true;
      menuExtraClock.ShowAMPM = lib.mkDefault false;
      dock = {
        autohide = lib.mkDefault true;
        show-recents = lib.mkDefault false; # Do not show recent apps in dock
        mru-spaces = lib.mkDefault false; # Do not automatically rearrange spaces based on most recent use
        expose-group-apps = lib.mkDefault true; # Group windows by apps in Mission Control
        # Hot corner action for corners
        # ref: https://github.com/nix-darwin/nix-darwin/blob/44a7d0e687a87b73facfe94fba78d323a6686a90/modules/system/defaults/dock.nix#L308
        wvous-tl-corner = lib.mkDefault 2; # top-left - Mission Control
        wvous-tr-corner = lib.mkDefault 4; # top-right - Desktop
        wvous-bl-corner = lib.mkDefault 3; # bottom-left - Application Windows
        wvous-br-corner = lib.mkDefault 11; # bottom-right - Launchpad
      };
      trackpad = {
        Clicking = lib.mkDefault true; # Tap (without vibration feedback) to click, may need restart to take affect
        TrackpadRightClick = lib.mkDefault true; # Two finger right click
        TrackpadThreeFingerDrag = lib.mkDefault true; # Three finger drag
      };
      finder = {
        _FXShowPosixPathInTitle = lib.mkDefault true;
        _FXSortFoldersFirst = lib.mkDefault true;
        AppleShowAllExtensions = lib.mkDefault true;
        AppleShowAllFiles = lib.mkDefault true; # Show hidden files
        FXDefaultSearchScope = lib.mkDefault "SCcf"; # Search scope to current folder
        FXEnableExtensionChangeWarning = lib.mkDefault false;
        FXPreferredViewStyle = lib.mkDefault "Nlsv"; # List view
        NewWindowTarget = lib.mkDefault "Home"; # Change default folder shown to home
        QuitMenuItem = lib.mkDefault true; # Allow quitting of the Finder
        ShowMountedServersOnDesktop = lib.mkDefault true;
        ShowPathbar = lib.mkDefault true; # Show path breadcrumbs in info bar
        ShowStatusBar = lib.mkDefault true; # show status bar
      };
      NSGlobalDomain = {
        AppleICUForce24HourTime = lib.mkDefault true; # Use 24-hour instead of based on region settings.
        # Configures the keyboard control behavior. Mode 3 enables full keyboard control
        AppleKeyboardUIMode = lib.mkDefault 3;
        NSAutomaticQuoteSubstitutionEnabled = lib.mkDefault false; # Disable auto quote substitution
      };
    };
    keyboard = {
      enableKeyMapping = lib.mkDefault true;
      remapCapsLockToEscape = lib.mkDefault true; # Remap caps lock to escape, useful for vim users
      userKeyMapping = [
        { # Remap escape to caps lock
          HIDKeyboardModifierMappingSrc = 30064771113;
          HIDKeyboardModifierMappingDst = 30064771129;
        }
      ];
    };
  };
}
