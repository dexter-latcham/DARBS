{
  config,
  pkgs,
  ...
}:
with pkgs; let
  patchDesktop = pkg: appName: from: to:
    lib.hiPrio (
      pkgs.runCommand "$patched-desktop-entry-for-${appName}" {} ''
        ${coreutils}/bin/mkdir -p $out/share/applications
        ${gnused}/bin/sed 's#${from}#${to}#g' < ${pkg}/share/applications/${appName}.desktop > $out/share/applications/${appName}.desktop
      ''
    );
  GPUOffloadApp = pkg: desktopName: patchDesktop pkg desktopName "^Exec=" "Exec=nvidia-offload ";
in 
{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ./../../modules/core
  ];
  services.libinput.touchpad.naturalScrolling = true;

  environment.systemPackages = with pkgs; [
    (GPUOffloadApp steam "steam")
    (GPUOffloadApp heroic "com.heroicgameslauncher.hgl")
    # asusctl
  ];
  # services.asusd = {
  #   enable = true;
  #   enableUserService = true;
  # };
  # services.supergfxd = {
  #   enable=true;
  #   settings = {
  #     mode = "Hybrid"; 
  #   };
  # };

  # environment.sessionVariables = {
  #   LIBVA_DRIVER_NAME = "nvidia";
  # };
  #

  environment.sessionVariables = {
    # WLR_NO_HARDWARE_CURSORS = "1";  # Fix cursor issues on Wayland
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # force opengl to use nvidia proprietry implementation
    # GBM_BACKEND = "nvidia-drm"; # tell gbm apps (vulkan, wayland compositors etc) to use nvidia gpu directly
    # LIBVA_DRIVER_NAME = "iHD";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # extraPackages = with pkgs; [
    #   intel-media-driver
    #   vpl-gpu-rt
    #   intel-vaapi-driver
      # libva-vdpau-driver# vdpau bridge for nvidia
      # libvdpau-va-gl #intel hardware accelerated video playback
      # vdpauinfo
    # ];
  };

  # hardware.bluetooth = {
  #   enable = true;
  #   powerOnBoot = true;
  #   settings = {
  #     General = {
  #       experimental = true;
  #       Privacy = "device";
  #       JustWorksRepairing = "always";
  #       Class = "0x000100";
  #       FastConnectable = true;
  #     };
  #   };
  # };

  # xbox controller support
  hardware.xpadneo.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
    # powerManagement.enable = false;
    nvidiaSettings = true;
    prime = {
      # sync.enable = true;
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0@0:2:0";
      nvidiaBusId = "PCI:1@0:0:0";
    };
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.enableRedistributableFirmware=true;
  boot = {
# https://wiki.nixos.org/wiki/Intel_Graphics#12th_Gen_(Alder_Lake)
    # kernelParams = [ "i915.force_probe=46a6" 
    #   "i915.enable_guc=3"
    # ];
    # kernelModules = [
      # "i915" # load intel gpu early for flicker free plymouth
    # ];
    # kernelParams = [
      # "video=efi:1920x1080@60"
    # ];
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
