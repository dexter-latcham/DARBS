{pkgs, lib, ...}:{
  boot = {
    plymouth = {
      enable = true;
      theme = lib.mkForce "rings";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };
    consoleLogLevel =3;
    initrd.systemd.enable=true;
    initrd.verbose =false;
    kernelParams = [
        "quiet"
        "splash"
        "intremap=on"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
    ];
    loader.timeout=0;
  };
}
