{ pkgs, config, lib, ... }:
{
  config = {
    programs = {
      slock.enable = true;
      steam.enable = true;
      zsh.enable = true;
      cdemu.enable = true;
      gnupg.agent.enable=true;
      thunar.enable = true;
      kdeconnect.enable = true;
    };



    services = {
      pipewire = {
        enable = true;

        alsa = {
          enable = true;
          support32Bit = true;
        };

        pulse.enable = true;
      };

      udisks2 = {
        enable = true;
        mountOnMedia = true;
      };

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

      gnome.gnome-keyring.enable = true;
      upower.enable = true;
    };


nixpkgs.config.permittedInsecurePackages = [
"qtwebengine-5.15.19"
];
    environment.systemPackages = with pkgs; [
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
  };

}
