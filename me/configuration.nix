{ config, lib, pkgs, myConfig,... }:
let
  inherit (builtins) attrValues;
in
{
  imports = attrValues myConfig.nixosModules;
  #nixpkgs.overlays = attrValues myConfig.overlays;
  home-manager.sharedModules = attrValues myConfig.homeModules;
  #environment.systemPackages = attrValues myConfig.packages.${pkgs.stdenv.hostPlatform.system};
  hardware.graphics = {
    enable=true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    prime = {
      sync.enable=true;
      intelBusId = "PCI:00:02:0";
      nvidiaBusId = "PCI:01:00:0";
    };
  };

nixpkgs.config.permittedInsecurePackages = [
"qtwebengine-5.15.19"
];

nixpkgs.overlays = [
  (final: prev: {
    dwm = prev.dwm.overrideAttrs (oldAttrs: rec {
      src = ../local/dwm;
      buildInputs = oldAttrs.buildInputs ++ [ pkgs.libxcb ];
      });
    })
  ];

  nixpkgs.config.allowUnfree=true;
  security.polkit.enable = true;
}

