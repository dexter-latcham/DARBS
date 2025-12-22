{ pkgs, config, lib, ... }:
{
  config = {
    hardware.bluetooth.enable = true;
    hardware.graphics.enable32Bit = true;

    programs = {
      steam.enable = true;
      zsh.enable = true;
      cdemu.enable = true;
      gnupg.agent.enable=true;
      thunar.enable = true;
    };


    console.keyMap="uk";

    services = {
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
        windowManager.dwm.enable = true;
        xkb = {
          layout="gb";
          variant="";
        };
        videoDrivers = ["nvidia"];
      };

      picom = {
        enable=true;
        backend="glx";
        vSync = true;
      };

      gnome.gnome-keyring.enable = true;
      upower.enable = true;
    };
    environment.systemPackages = with pkgs; [
      stremio
        vim wget neovim fontconfig
        xorg.xinit xorg.xrdb xorg.xsetroot xorg.xev
        gnumake
        xorg.libX11.dev
        xorg.libXft
        xorg.libXinerama
        xorg.libxcb
        gtk3 gtk4 xdg-desktop-portal-gtk
        alacritty
        pulsemixer
        git
        gnumake
	librewolf
        gcc
	spotify
        freetype
        libx11
        libxft
        autorandr
        dmenu
        vesktop
        (st.overrideAttrs (oldAttrs: rec {
                           src = fetchFromGitHub {
                           owner = "LukeSmithxyz";
                           repo = "st";
                           rev = "62ebf677d3ad79e0596ff610127df5db034cd234";
                           sha256 = "L4FKnK4k2oImuRxlapQckydpAAyivwASeJixTj+iFrM=";
                           };
                           buildInputs = oldAttrs.buildInputs ++ [ harfbuzz ];
                           }))
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
    ];
  };
}
