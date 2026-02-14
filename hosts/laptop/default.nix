{
  config,
  pkgs,
  ...
}:
# with pkgs; let
#   patchDesktop = pkg: appName: from: to:
#     lib.hiPrio (
#       pkgs.runCommand "$patched-desktop-entry-for-${appName}" {} ''
#         ${coreutils}/bin/mkdir -p $out/share/applications
#         ${gnused}/bin/sed 's#${from}#${to}#g' < ${pkg}/share/applications/${appName}.desktop > $out/share/applications/${appName}.desktop
#       ''
#     );
#   GPUOffloadApp = pkg: desktopName: patchDesktop pkg desktopName "^Exec=" "Exec=nvidia-offload ";
# in 
{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ./../../modules/core
  ];

  # environment.systemPackages = with pkgs; [
  #   (GPUOffloadApp steam "steam")
  #   (GPUOffloadApp heroic "com.heroicgameslauncher.hgl")
  # ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";  # Fix cursor issues on Wayland
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
    ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        experimental = true;
        Privacy = "device";
        JustWorksRepairing = "always";
        Class = "0x000100";
        FastConnectable = true;
      };
    };
  };

  # xbox controller support
  hardware.xpadneo.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    powerManagement.enable = true;
    nvidiaSettings = true;
    prime = {
      sync.enable = true;
      # offload = {
      #   enable = true;
      #   enableOffloadCmd = true;
      # };
      intelBusId = "PCI:00:02:0";
      nvidiaBusId = "PCI:01:00:0";
    };
  };

  services.xserver.videoDrivers = ["nvidia"];

  boot = {
    kernelModules = [
      "i915" # load intel gpu early for flicker free plymouth
    ];
    kernelParams = [
      "video=efi:1920x1080@60"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    extraModulePackages = with config.boot.kernelPackages; [xpadneo];
    extraModprobeConfig = ''
      options bluetooth disable_ertm=Y
    '';
  };

  services.fwupd.enable = true; # Firmware updater # fwupdmgr --help

  fileSystems."/mnt/nasData" = {
    device = "192.168.8.167:/mnt/MainPool/pc-share";
    fsType = "nfs";

    options = [
      "x-systemd.automount" # mount on first access
      "noauto"
      "x-systemd.idle-timeout=600" # Optional: disconnects after 10 mins idle
      "x-systemd.device-timeout=5s" # Time to wait for network before failing
      "x-systemd.mount-timeout=5s"
    ];
  };
}
