{inputs, pkgs, lib, ...}:{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];

  environment.persistence."/persist".directories = [
    "/var/lib/flatpak/"
  ];
  services.flatpak = {
    enable = true;
    # update.auto.enable = true;
    # uninstallUnmanaged = true;
    update.onActivation = true;
  };
  # Add here the flatpaks you want to install
  services.flatpak.packages = [
    "in.cinny.Cinny"
    rec {
      appId = "chat.commet.commetapp.flatpak";
      sha256 = "0x6cgkq0ndcxkvfh2v1cf6zj74lwj40hz73hj43x70x5c744h5il";
      bundle = "${pkgs.fetchurl {
        url = "https://github.com/commetchat/commet/releases/download/v0.4.0/chat.commet.commetapp.flatpak";
        inherit sha256;
      }}";
    }
  ];
}
