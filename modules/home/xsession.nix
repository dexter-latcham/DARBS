{pkgs, config, ...}:
{
  xsession = {
    enable = true;
    initExtra = ''
      ${pkgs.vesktop}/bin/vesktop --start-minimized  &
      ${pkgs.signal-desktop}/bin/signal-desktop --start-in-tray --no-sandbox &
      ${pkgs.steam}/bin/steam -silent &
    '';
  };
}
