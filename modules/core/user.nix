{
  pkgs,
  self,
  inputs,
  username,
  host,
  ...
}: {
  imports = [inputs.home-manager.nixosModules.home-manager];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit self inputs username host;};
    users.${username} = {
      imports = [./../home];
      home.username = "${username}";
      home.homeDirectory = "/home/${username}";
      home.stateVersion = "26.05";
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
      "gamemode"
    ];
    shell = pkgs.zsh;

    hashedPassword = "$6$2LuiqXfchJhaARg/$VNBv17B/oZ7Wc6sHY/hRLFULq4ASTpcs71NEKSRkeMlmCb11wNNp2VRVNaf0vNOz48IPXNvwffBXrOopt6c/g0";
  };
  nix.settings.allowed-users = ["${username}"];
}
