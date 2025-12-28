{ config, pkgs, ... }:
{
  # Make sure xdg-utils is installed so xdg-open works
  home.packages = [
    pkgs.xdg-utils
  ];

  # Set MIME types / default apps
  xdg.desktopEntries.librewolf = {
    name = "LibreWolf";
    exec = "${pkgs.librewolf}/bin/librewolf";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
      "application/pdf" = "zaread.desktop";
      "inode/directory" = "thunar.desktop";
    };
  };

  # Optional: set the BROWSER env var for CLI apps
  home.sessionVariables.BROWSER = "librewolf";
}
