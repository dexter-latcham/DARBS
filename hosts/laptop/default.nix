{pkgs, ... }:
with pkgs; let
  patchDesktop = pkg: appName: from: to: lib.hiPrio (
    pkgs.runCommand "$patched-desktop-entry-for-${appName}" {} ''
      ${coreutils}/bin/mkdir -p $out/share/applications
      ${gnused}/bin/sed 's#${from}#${to}#g' < ${pkg}/share/applications/${appName}.desktop > $out/share/applications/${appName}.desktop
      '');
  GPUOffloadApp = pkg: desktopName: patchDesktop pkg desktopName "^Exec=" "Exec=nvidia-offload ";
in
{
  imports = [./hardware-configuration.nix
    ./../../modules/core
  ];

  environment.systemPackages = with pkgs; [
    (GPUOffloadApp steam "steam")
    (GPUOffloadApp heroic "com.heroicgameslauncher.hgl")
  ];

  hardware.graphics = {
    enable=true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver


  hardware.bluetooth.enable = true;
  hardware.nvidia = {
    modesetting.enable=true;
    open = false;
    nvidiaSettings = true;
    prime = {
      offload = {
	      enable = true;
	      enableOffloadCmd=true;
      };
      intelBusId = "PCI:00:02:0";
      nvidiaBusId = "PCI:01:00:0";
    };
  };

  services.xserver.videoDrivers = ["nvidia"];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
