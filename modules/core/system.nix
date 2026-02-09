{pkgs, ...}: {
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
      substituters = [
        "https://cache.nixos.org"
        "https://devenv.cachix.org"
        "https://nix-community.cachix.org" # Nix community's cache server
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" # Nix community's cache server
      ];
    };
    optimise = {
      automatic = true;
      dates = "weekly";
    };
  };

  console.keyMap = "uk";
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  system.stateVersion = "26.05";
  nixpkgs.config.allowUnfree = true;

  services = {
    dbus.enable = true;

    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
    gnome.gnome-keyring.enable = true;
    upower.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nfs-utils
  ];
}
