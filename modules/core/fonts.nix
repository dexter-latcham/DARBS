{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = false;

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.tinos
      nerd-fonts.arimo
      aleo-fonts
        noto-fonts
        noto-fonts-cjk-serif
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        maple-mono.variable
        font-awesome
        nerd-fonts.noto
        kanji-stroke-order-font
        liberation_ttf
    ];

    fontconfig = {
      defaultFonts = {
      monospace = [ "FiraCode Nerd Font Mono"];	
      sansSerif = [ "Arimo Nerd Font"];
      serif = [ "Tinos Nerd Font" ];
      };

      allowBitmaps = false;
    };
  };
}
