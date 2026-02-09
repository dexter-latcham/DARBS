{pkgs,...}:{

  home.persistence."/persist".directories = [
		".config/Signal"
	];

  xsession = {
    initExtra = ''
      ${pkgs.signal-desktop}/bin/signal-desktop --start-in-tray --no-sandbox &
    '';
  };

  home.packages = with pkgs; [
    signal-desktop
  ];
}
