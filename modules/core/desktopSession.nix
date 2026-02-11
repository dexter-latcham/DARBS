{
  pkgs,
  username,

  ...
}: {
  imports = [./suckless];

  programs = {
    slock.enable = true;
    zsh.enable = true;
    cdemu.enable = true;
    gnupg.agent.enable = true;
    thunar.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config.common.default = ["gtk"];
  };

  services = {
    displayManager.autoLogin = {
      enable = true;
      user = "dex";
    };
    xserver = {
      enable = true;
      autoRepeatDelay = 200;
      autoRepeatInterval = 35;

      displayManager.lightdm.greeter.enable = false;
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
        layout = "gb";
        variant = "";
      };
    };

    picom = {
      enable = true;
      backend = "glx";
      vSync = true;
    };
  };

  environment.systemPackages = [
    pkgs.r2modman
    pkgs.devenv
    pkgs.nodejs
    #pkgs.lmstudio
    pkgs.notion
    pkgs.xwallpaper
    pkgs.libxinerama
    pkgs.xclip
    (pkgs.callPackage ./stremio-linux-shell.nix {})
    pkgs.teamspeak6-client
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
    pkgs.xorg.libXft
    pkgs.xorg.libXinerama
    pkgs.xorg.libxcb
    pkgs.gtk3
    pkgs.gtk4
    pkgs.alacritty
    pkgs.pulsemixer
    pkgs.gnumake
    pkgs.gcc
    pkgs.freetype
    pkgs.libx11
    pkgs.libxft
    pkgs.autorandr
    pkgs.dmenu
    pkgs.qbittorrent
    pkgs.texliveFull
    #pkgs.sqlitebrowser
    #pkgs.qdiskinfo
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
