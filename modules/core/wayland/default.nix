{pkgs,lib,config,...}:{
  imports = [./dwl/dwl.nix];
  # programs.uwsm = {
  #   enable = true;
  #   waylandCompositors = {
  #     dwl = {
  #       prettyName = "dwl";
  #       binPath = "${pkgs.dwl}/bin/dwl";
  #     };
  #   };
  # };
  # services.dbus.implementation = lib.mkForce "dbus"

  programs.dwl.enable=true;
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";  # Fix cursor issues on Wayland
    # MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    # # __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # force opengl to use nvidia proprietry implementation
    # __VK_LAYER_NV_optimus="NVIDIA_only";
  };

  # services.logind.enable = true;
  xdg.portal = {
    wlr.enable = true;
    extraPortals = with pkgs;[xdg-desktop-portal-wlr];
    xdgOpenUsePortal = true;
  };
  # programs.dwl = {
  #   enable = true;
  #   extraSessionCommands = ''
  #     export TESTING=1
  #   '';
  # };
  # programs.xwayland.enable = true;
  environment.systemPackages = with pkgs;[
    dwl
    foot
    waybar
    alacritty
    wget
    wmenu
    wlr-randr
    wl-clipboard
  ];
}
