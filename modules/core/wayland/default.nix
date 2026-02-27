{pkgs,...}:{
imports = [./dwl/dwl.nix];
  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.dwl}/bin/dwl";
          user = "dex";
        };
      };
    };
  };
  environment.systemPackages = with pkgs;[
    dwl
    foot
    waybar
    kitty
    wget
    wmenu
    wlr-randr
    wl-clipboard
  ];
}
