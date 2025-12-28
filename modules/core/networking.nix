{pkgs, host, ...}:
{
  networking = {
    hostName="${host}";
    networkmanager = {
      enable = true;
      wifi.macAddress = "random";
      ethernet.macAddress = "random";
    };
  };
}
