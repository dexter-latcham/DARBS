{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    spotify
  ];
  #local file discovery 57621
  #google home devices 5353
  networking.firewall.allowedTCPPorts = [ 57621 5353 ];
}
