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
      displayManager.sessionCommands = ''
        xset s off
        xset -dpms
        xset s noblank
      '';
      xautolock = {
        enable = true;
        locker = "${pkgs.slock}/bin/slock";
        notifier = "${pkgs.libnotify}/bin/notify-send 'locking shortly'";
      };

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

  environment.systemPackages = [
    pkgs.nodejs
    pkgs.lmstudio
    pkgs.notion
    pkgs.xwallpaper
    pkgs.pywal
    pkgs.libxinerama
    pkgs.xclip
    pkgs.stremio
    pkgs.vim
    pkgs.wget
    pkgs.neovim
    pkgs.fontconfig
    pkgs.xorg.xinit
    pkgs.xorg.xrdb
    pkgs.xorg.xsetroot
    pkgs.xorg.xev
    pkgs.gnumake
    pkgs.xorg.libX11.dev
    pkgs.github-cli
    pkgs.xorg.libXft
    pkgs.xorg.libXinerama
    pkgs.xorg.libxcb
    pkgs.gtk3
    pkgs.gtk4
    pkgs.xdg-desktop-portal-gtk
    pkgs.alacritty
    pkgs.pulsemixer
    pkgs.git
    pkgs.gnumake
    pkgs.gcc
    pkgs.freetype
    pkgs.libx11
    pkgs.libxft
    pkgs.autorandr
    pkgs.dmenu
    pkgs.vesktop
    pkgs.discord
    pkgs.signal-desktop-bin
    pkgs.qbittorrent
    pkgs.texliveFull
    pkgs.sqlitebrowser
    pkgs.qdiskinfo
    pkgs.vlc
    pkgs.picard
    pkgs.pulseaudio
    pkgs.pavucontrol
    pkgs.libnotify
    pkgs.google-chrome
    pkgs.feh
    pkgs.dunst
    pkgs.unzip
    pkgs.arandr
    pkgs.st
    pkgs.acpi
  ];

}
