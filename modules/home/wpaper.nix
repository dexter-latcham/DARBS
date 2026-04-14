{pkgs, ...}: {
  services.wpaperd = {
    enable =true;
    settings = {
      eDP-1 = {
        path = "/etc/nixos/walls/catppuccin.jpg";
      };
    };
  };
}
