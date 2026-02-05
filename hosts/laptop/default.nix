{config, pkgs, ... }:
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
    ./disko-config.nix
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


  hardware.bluetooth = {
    enable = true;
    powerOnBoot=true;
    settings = {
      General = {
        experimental=true;
        Privacy = "device";
        JustWorksRepairing = "always";
        Class = "0x000100";
        FastConnectable = true;
      };
    };
  };
  services.blueman.enable = true;
  # xbox controller support
  hardware.xpadneo.enable=true;

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
      efi.canTouchEfiVariables = true;
      limine = {
        enable = true;
        secureBoot.enable = false;
        maxGenerations = 10;
      };
    };
    extraModulePackages = with config.boot.kernelPackages; [ xpadneo ];
    extraModprobeConfig = ''
      options bluetooth disable_ertm=Y
    '';
  };

  services.udev.extraRules = ''
    #dont disable microphone
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="0ab7", TEST=="power/control", ATTR{power/control}="on"
  '';


  services.fwupd.enable = true; # Firmware updater # fwupdmgr --help

  services.getty.autologinUser = "dex";
  # fileSystems."/mnt/nasData" = {
  #   device = "192.168.8.167:/mnt/MainPool/pc-share";
  #   fsType = "nfs";
  #
  #   options = [
  #     "x-systemd.automount"   # mount on first access
  #     "noatime"
  #     "nofail"                # don't fail boot if NAS is offline
  #     "_netdev"               # wait for network
  #   ];
  # };
}
