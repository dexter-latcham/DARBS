{
  pkgs,
  username,

  ...
}: {
  imports = [./wayland];

  programs = {
    zsh.enable = true;
    cdemu.enable = true;
    gnupg.agent.enable = true;
    thunar.enable = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal =true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    # config = {
      # common.default = ["gtk"];
      # hyprland.default = [
      #   "gtk"
        # "hyprland"
      # ];
    # };
  };

  security.polkit.enable = true;
  programs.dconf.enable = true;

  # programs.hyprland = {
  #   enable = true;
  #   # withUWSM = true;
  #   xwayland.enable = true;
  # };

  services = {
    # seatd.enable = true;
    # getty.autologinUser = "dex";
    xserver = {
      enable = true;
      xkb.layout = "gb";
    };
    # displayManager.autoLogin = {
    #   enable = true;
    #   user = "dex";
    # };
    # libinput.enable = true;
  };

  environment.systemPackages = with pkgs;[

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
