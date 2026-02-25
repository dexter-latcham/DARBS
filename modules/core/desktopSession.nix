{
  pkgs,
  username,

  ...
}: {
  # imports = [./suckless];

  programs = {
    zsh.enable = true;
    cdemu.enable = true;
    gnupg.agent.enable = true;
    thunar.enable = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config.common.default = ["gtk"];
  };

  security.polkit.enable = true;
  programs.dconf.enable = true;
  services.seatd.enable = true;
  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.dwl}/bin/dwl";
          user = "dex";
        };
      };
    };
  };

  environment.systemPackages = with pkgs;[
    dwl
    foot
    wlr-randr
    wl-clipboard

    r2modman
    devenv
    nodejs
    #pkgs.lmstudio
    notion
    (callPackage ./stremio-linux-shell.nix {})
   teamspeak6-client
   vim
   wget
   neovim
   fontconfig
   gnumake
   gtk3
   gtk4
   alacritty
   pulsemixer
   gnumake
   gcc
   freetype
   qbittorrent
   texliveFull
   sqlitebrowser
   qdiskinfo
   vlc
   pavucontrol
   libnotify
   google-chrome
   feh
   dunst
   unzip
   acpi
   pkg-config
  ];
}
