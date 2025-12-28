{pkgs, config, ...}:
{
  home.packages = with pkgs; [
    autorandr
    feh
  ];

  programs.autorandr = {
    enable = true;
    hooks.postswitch = {
      set-wallpaper = ''
        ${pkgs.xwallpaper}/bin/xwallpaper --zoom /etc/nixos/walls/current &
      '';
    };
  };
  xsession.initExtra = ''
    autorandr --change
  '';
}
