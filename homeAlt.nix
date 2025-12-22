{ pkgs, config, lib, inputs, flake-root, ... }:
let
xresourcesConfig = ''
    ! ~/.Xresources for blfnix
    Xft.autohint: 0
    Xft.lcdfilter: lcddefault
    Xft.hintstyle: hintslight
    Xft.hinting: 1
    Xft.antialias: 1
    Xft.rgba: rgb

    Xcursor.theme: Adwaita
    Xcursor.size: 12

    *faceName: monospace
    *faceSize: 9
    *cursorBlink: false
    *saveLines: 10000
    *selectToClipboard: true
    ! Normal cut & paste key conventions ( ctrl-shift c/v )
    *VT100.Translations: #override \
    Ctrl Shift <Key>V:    insert-selection(CLIPBOARD) \n\
    Ctrl Shift <Key>C:    copy-selection(CLIPBOARD) \n\

    ! Optional: Generic Xterm colors if some apps use them as fallback
    ! st will primarily use colors defined in its config.h
    *.background:   #242424
    *.foreground:   #dedede
    *.cursorColor:  #f0f0f0
    *.color0:       #1e1e1e
    *.color1:       #c01c28
    *.color2:  #2ec27e
    *.color3:  #e5a50a
    *.color4:  #3584e4
    *.color5:  #813d9c
    *.color6:  #33d7a0
    *.color7:  #dedede
    *.color8:  #5e5c64
    *.color9:  #ed333b
    *.color10: #57e389
    *.color11: #f8e45c
    *.color12: #62a0ea
    *.color13: #9141ac
    *.color14: #57d7a0
    *.color15: #ffffff
  '';
  in
{
  home.username= "dex";
  home.homeDirectory = "/home/dex";
  home.stateVersion = "25.11";

  # This is the declarative way to add directories to your PATH.
  # It correctly appends to the path without breaking other environment variables.
  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
  ];

  xdg.userDirs = {
    enable = true;
	createDirectories=true;
  };

  home.packages = with pkgs; [
    xorg.xev polkit_gnome
    p7zip gnupg curl file tree sqlite xdg-utils mpv
    ffmpeg cmus qbittorrent gimp3 libreoffice librewolf

    tmux pass keychain git gh fd ripgrep bat jq xclip
    poppler-utils zathura
    pulseaudio
    pulsemixer
    htop
    neovim
    github-cli

    vesktop 
    python313 uv nodejs_24 zsh-autocomplete

    cmake ninja gnumake
    llvmPackages_20.clang llvmPackages_20.llvm llvmPackages_20.lld
    llvmPackages_20.clang-tools llvmPackages_20.lldb
  ];

  home.file.".Xresources" = {
    text = xresourcesConfig;
  };


  #programs.keychain = { enable = true; agents = [ "ssh" ]; keys = [ "id_ecdsa" ]; };
  
  programs.git = {
    enable = true;
    userName = "dexter-latcham";
    userEmail = "flatcapdex@pm.me";
    extraConfig = { core.editor = "nvim"; init.defaultBranch = "main"; };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [ "--height 40%" "--layout=reverse" "--border" "--prompt='➜  '" ];
  };
 programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      adjust-open = "best-fit";
      default-bg = "#212121";
      default-fg = "#303030";
      statusbar-fg = "#B2CCD6";
      statusbar-bg = "#353535";
      inputbar-bg = "#212121";
      inputbar-fg = "#FFFFFF";
      notification-bg = "#212121";
      notification-fg = "#FFFFFF";
      notification-error-bg = "#212121";
      notification-error-fg = "#F07178";
      notification-warning-bg = "#212121";
      notification-warning-fg = "#F07178";
      highlight-color = "#FFCB6B";
      highlight-active-color = "#82AAFF";
      completion-bg = "#303030";
      completion-fg = "#82AAFF";
      completion-highlight-fg = "#FFFFFF";
      completion-highlight-bg = "#82AAFF";
      recolor-lightcolor = "#212121";
      recolor-darkcolor = "#EEFFFF";
      recolor = false;
      recolor-keephue = false;
    };
  }; 
# --- Home Manager Session Variables ---
  home.sessionVariables = {
    EDITOR = "nvim"; VISUAL = "nvim"; PAGER = "less";
    CC = "clang"; CXX = "clang++";
    GIT_TERMINAL_PROMPT = "1";
    FZF_ALT_C_COMMAND = "fd --type d --hidden --follow --exclude .git";
    TERMINAL = "st"; # Your custom ST
    BROWSER = "librewolf";

    # Consolidated theme variables
    # GTK_THEME = "Adwaita-dark";
    # Use the forceful "Theme:Variant" syntax to ensure dark mode is applied, bypassing
    # the complex settings daemons and portal infrastructure that are absent in a minimal
    # window manager setup - libreoffice, firefox, brave browser to respect settings
    GTK_THEME = "Adwaita:dark"; # <-- THIS IS THE FIX
    QT_STYLE_OVERRIDE = "adwaita-dark";
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };
}
