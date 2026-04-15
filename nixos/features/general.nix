{self, ...}: {
  flake.nixosModules.general = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      self.nixosModules.extra_hjem
      self.nixosModules.nix
    ];

    users.users.${config.preferences.user.name} = {
      isNormalUser = true;
      description = "${config.preferences.user.name}'s account";
      extraGroups = ["wheel" "networkmanager"];
      shell = self.packages.${pkgs.system}.environment;

      hashedPassword = "$6$2LuiqXfchJhaARg/$VNBv17B/oZ7Wc6sHY/hRLFULq4ASTpcs71NEKSRkeMlmCb11wNNp2VRVNaf0vNOz48IPXNvwffBXrOopt6c/g0";
    };

    persistance.data.directories = [
      "Downloads"
      "Music"
      "Pictures"
      "Documents"
      "Videos"
      ".ssh"
      ".local/share/direnv"

      ".local/share/zoxide"
      ".local/share/direnv"
      ".local/share/nvim"
      ".local/share/zsh"
    ];
  };
}
