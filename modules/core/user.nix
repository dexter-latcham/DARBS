{ pkgs, inputs, username, host, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs username host; };
    users.${username} = {
      imports = [ ./../home ];
      home.username = "${username}";
      home.homeDirectory = "/home/${username}";
      home.stateVersion = "25.11";
      programs.home-manager.enable = true;
    };
    backupFileExtension = "hm-backup";
  };

  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"
    ];
    shell = pkgs.zsh;
  };
  nix.settings.allowed-users = [ "${username}" ];
}
