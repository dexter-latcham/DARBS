
{self, ...}: {
  flake.nixosModules.x11 = {
    pkgs, ...
  }:{

    programs.slock.enable = true;

    xserver = {
      enable = true;
      autoRepeatDelay = 200;
      autoRepeatInterval = 35;
      xkb = {
        layout = "gb";
        variant = "";
      };

      # disable screen saver blanking
      displayManager.sessionCommands = ''
        xset s off
        xset -dpms
        xset s noblank
      '';

    };
  };
}
