{...}: {
  imports = [
    ./plymouth.nix
    ./impermanence.nix
    ./system.nix
    ./audio.nix
    ./networking.nix
    ./desktopSession.nix
    ./shell.nix
    ./user.nix
    # ./virtualisation.nix
    ./stylix.nix
    ./steam.nix
    ./pia.nix
    ./security.nix
    ./flatpak.nix
    ./tooling.nix
    ./lmstudio.nix
    ./wayland/default.nix
    ./kdeconnect.nix
  ];
}
