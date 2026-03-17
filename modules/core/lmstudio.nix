{pkgs, ...}:{
  environment.systemPackages = with pkgs;[
    lmstudio
  ];

  environment.persistence."/persist".directories = [
    "/home/dex/.lmstudio"
  ];
}
