{config, inputs, pkgs, ...}:{
  imports = [inputs.pia.nixosModules.default];
  services.pia = {
    enable = true;
    credentials = {
    };
    protocol = "wireguard";
    autoConnect.enable = false;
  };
}
