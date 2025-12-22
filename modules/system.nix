{
  myConfig,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = with myConfig.inputs.home-manager.nixosModules; [ home-manager ];
  config = {
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };

    nix = {
      settings = {
        auto-optimise-store = true;
        warn-dirty = false;
        allow-import-from-derivation = false;
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

    time.timeZone = "Europe/London";

    i18n.defaultLocale = "en_GB.UTF-8";

    system.stateVersion = "25.11"; # Did you read the comment?

    users = {
      users.dex = {
        isNormalUser = true;
        extraGroups =
            [
              "wheel"
              "networkmanager"
              "video"
              "input"
            ];
      };
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";

      users.dex.home = {
        homeDirectory = "/home/dex";
        stateVersion = "25.11";
      };
    };

    networking = {
      hostName="nixtop";
      networkmanager = {
        enable = true;
        wifi.macAddress = "random";
        ethernet.macAddress = "random";
      };
    };


    virtualisation.docker = {
      enable = true;

      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    programs.command-not-found.enable = false;
  };
}
