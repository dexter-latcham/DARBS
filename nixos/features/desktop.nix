{self, ...}: {
  flake.nixosModules.desktop = {pkgs, ...}: let
    selfpkgs = self.packages."${pkgs.system}";
  in {
    imports = [
      self.nixosModules.pipewire
      self.nixosModules.dwm
    ];


    environment.systemPackages = [
      selfpkgs.terminal
    ];

    fonts.packages = with pkgs; [
      dejavu_fonts
      nerd-fonts.jetbrains-mono
      noto-fonts-color-emoji
    ];

    fonts.fontconfig.defaultFonts = {
      serif = ["DejaVu Serif"];
      sansSerif = ["DejaVu Sans"];
      monospace = ["JetBrains Mono Nerd Font"];
      emoji = ["Noto Color Emoji"];
    };


    console.keyMap = "uk";
    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";

    services.upower.enable = true;

    security.polkit.enable = true;

    hardware = {
      enableAllFirmware = true;

      bluetooth.enable = true;
      bluetooth.powerOnBoot = true;
    };
  };
}
