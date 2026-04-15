{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.nixtop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.hostLaptop
    ];
  };

  flake.nixosModules.hostLaptop = {pkgs, ...}: {
    imports = [
      self.nixosModules.base
      self.nixosModules.general
      self.nixosModules.desktop

      self.nixosModules.impermanence

      # disko
      inputs.disko.nixosModules.disko
      self.diskoConfigurations.hostLaptop
    ];

    programs.corectrl.enable = true;

    boot = {
      kernelPackages = pkgs.linuxPackages_latest;

      # loader.grub.enable = true;
      # loader.grub.efiSupport = true;
      # loader.grub.efiInstallAsRemovable = true;
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      supportedFilesystems.ntfs = true;

      kernelParams = ["quiet"];
      kernelModules = ["coretemp" "cpuid"];

      binfmt.emulatedSystems = ["aarch64-linux"];
    };

    boot.plymouth.enable = true;

    networking = {
      hostName = "nixtop";
      networkmanager = {
        enable = true;
        wifi.macAddress = "random";
        ethernet.macAddress = "random";
      };
    };

    systemd.services.NetworkManager-wait-online.enable = false;

    virtualisation.libvirtd.enable = true;
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };


    services = {
      flatpak.enable = true;
      udisks2.enable = true;
      printing.enable = true;
    };

    environment.systemPackages = with pkgs; [
      winetricks
      glib
    ];

    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
    xdg.portal.enable = true;


    # programs.niri.enable = true;

    networking.firewall.enable = false;
    programs.appimage.enable = true;
    programs.appimage.binfmt = true;


    system.stateVersion = "26.05";


    services.fwupd.enable = true; # Firmware updater # fwupdmgr --help
    services.libinput.touchpad.naturalScrolling = true;


    hardware.cpu.intel.updateMicrocode = true;

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

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
    boot.initrd.kernelModules = ["nvidia"];
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
  };
}
