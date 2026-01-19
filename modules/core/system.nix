{ pkgs, ... }:
{
  nix = {
    settings = {
      auto-optimise-store = true;
      warn-dirty = false;
      allow-import-from-derivation = true;
      keep-going = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-users = [
        "root"
        "@wheel"
      ];
    };
  };


  boot.loader.timeout = 0;

  console.keyMap="uk";
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  system.stateVersion = "25.11";
  nixpkgs.config.allowUnfree=true;

  services = {
    dbus.enable=true;

    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
    gnome.gnome-keyring.enable = true;
    upower.enable = true;
  };
}
