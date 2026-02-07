{ congig, pkgs, ... }:
{
  home.persistence."/persist".files = [
	];
  programs.firefox = {
    enable = true;
  };
}
