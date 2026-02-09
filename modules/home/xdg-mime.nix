{
  config,
  pkgs,
  ...
}: {
  xdg = {
    enable = true;
    mime.enable = true;
  };

  #home.packages = [
  #  pkgs.xdg-utils
  #];

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
