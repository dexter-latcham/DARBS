{pkgs, config, lib,...}:
{
  home.persistence."/persist".directories = [
    ".config/kdeconnect"
  ];

  programs.kdeconnect.enable = true;
  xsession = {
    initExtra = ''
      kdeconnectd &
    '';
  };
  xdg.configFile.kdeglobals = lib.mkIf(config ? lib.stylix){
    source =
      let
        themePackage = builtins.head (
          builtins.filter (
            p: builtins.match ".*stylix-kde-theme.*" (builtins.baseNameOf p) != null
          ) config.home.packages
        );
        colorSchemeSlug = lib.concatStrings (
          lib.filter lib.isString (builtins.split "[^a-zA-Z]" config.lib.stylix.colors.scheme)
        );
      in
        "${themePackage}/share/color-schemes/${colorSchemeSlug}.colors";
    };
  }
