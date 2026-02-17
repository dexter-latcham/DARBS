{pkgs, ...}:{
  environment.systemPackages = with pkgs; [
    libsecret
    seahorse
  ];
  # dbus api for apps to store secrets
  services.gnome.gnome-keyring.enable = true;
  # lightdm unlock gnome keyring
  security.pam.services.lightdm.enableGnomeKeyring = true;
}
