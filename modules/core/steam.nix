{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    steam-run
    protonup-qt
  ];

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      extraCompatPackages = with pkgs; [
        proton-ge-bin # Use Proton GE as an extra compatibility package
      ];
    };

    gamemode.enable = true;
  };
  environment.persistence."/persist".users.dex.directories = [
    ".steam"
    ".local/share/Steam"
  ];
}
