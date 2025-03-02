{
  modules.desktop = {
    hyprland = {
      enable = true;
      settings = {
        # Configure your Display resolution, offset, scale and Monitors here, use `hyprctl monitors` to get the info.
        #   highres:      get the best possible resolution
        #   auto:         position automatically
        #   1.5:          scale to 1.5 times
        #   bitdepth,10:  enable 10 bit support
        monitor = "eDP-1,highres,auto,1.5,bitdepth,10";
      };
    };
  };
  # modules.editors.emacs = {
    # enable = true;
  # };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      # a private key that is used during authentication will be added to ssh-agent if it is running
      AddKeysToAgent yes

      Host 192.168.*
        # allow to securely use local SSH agent to authenticate on the remote machine.
        # It has the same effect as adding cli option `ssh -A user@host`
        ForwardAgent yes
        # romantic holds my homelab~
        IdentityFile /etc/agenix/ssh-key-romantic
        # Specifies that ssh should only use the identity file explicitly configured above
        # required to prevent sending default identity files first.
        IdentitiesOnly yes

      Host gtr5
        HostName 192.168.5.172
        Port 22

      Host um560
        HostName 192.168.5.173
        Port 22

      Host s500plus
        HostName 192.168.5.174
        Port 22

      Host github.com
          IdentityFile ~/.ssh/idols-ai
          # Specifies that ssh should only use the identity file explicitly configured above
          # required to prevent sending default identity files first.
          IdentitiesOnly yes
    '';
  };
}
