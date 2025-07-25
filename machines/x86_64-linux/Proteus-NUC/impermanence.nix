{myvars, ...}: {
  environment.persistence."/persistent".users.${myvars.username} = {
    directories = [
      "Downloads"
      "Music"
      "Pictures"
      "Documents"
      "Videos"

      # Games
      ".steam" # Steam games

      # Remote desktop
      ".config/remmina"
      ".config/freerdp"

      # vscode
      ".vscode"
      ".vscode-insiders"
      ".config/Code/User"
      ".config/Code - Insiders/User"

      # zed editor
      ".config/zed"

      # Browsers
      ".mozilla"
      ".config/google-chrome"

      # Others
      ".config/blender"
      ".config/LDtk"

      # IM
      ".config/QQ"
      ".xwechat"
    ];
    files = [];
  };
}
