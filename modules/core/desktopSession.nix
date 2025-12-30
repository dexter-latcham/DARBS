{pkgs, username, ... }:
{
  imports = [./suckless];
    programs = {
      slock.enable = true;
      steam.enable = true;
      zsh.enable = true;
      cdemu.enable = true;
      gnupg.agent.enable=true;
      thunar.enable = true;
      kdeconnect.enable = true;
    };


  xdg.portal = {
      enable = true;
      extraPortals = with pkgs;[
        xdg-desktop-portal-gtk
      ];
config.common.default = ["gtk"];
    };
  services = {
    displayManager.ly.enable=true;
    xserver = {
      enable=true;
      autoRepeatDelay=200;
      autoRepeatInterval=35;
      windowManager.qtile.enable=true;
      windowManager.dwm.enable=true;
      xkb = {
        layout="gb";
        variant="";
      };
    };

    picom = {
      enable = true;
      backend="glx";
      vSync = true;
    };
  };
  nixpkgs.config.permittedInsecurePackages = [
  "qtwebengine-5.15.19"
  ];
    environment.systemPackages = with pkgs; [
  papirus-icon-theme
      xwallpaper
      pywal
      libxinerama
      xclip
      tree-sitter
      stremio
        vim wget neovim fontconfig
        xorg.xinit xorg.xrdb xorg.xsetroot xorg.xev
        gnumake
        xorg.libX11.dev
	github-cli
        xorg.libXft
        xorg.libXinerama
        xorg.libxcb
        gtk3 gtk4 xdg-desktop-portal-gtk
        alacritty
        pulsemixer
        git
        gnumake
        gcc
	spotify
        freetype
        libx11
        libxft
        autorandr
        dmenu
        vesktop
    signal-desktop-bin
      qbittorrent
      texliveFull
      sqlitebrowser
      qdiskinfo
      vlc
      picard
      pulseaudio
      pavucontrol
      libnotify
	lunarvim
google-chrome
    feh
    dunst
    unzip
    arandr
    st
    ];

}
