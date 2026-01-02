{ config, pkgs, lib, ... }:
let
	pwrMgrScript = pkgs.writeShellScriptBin "pwrMgr" ''
    #!/usr/bin/env sh
		case "$(printf "🔒 lock\n🚪 leave dwm\n♻️ renew dwm\n🐻 hibernate\n🔃 reboot\n🖥️shutdown\n💤 sleep\n📺 display off" | dmenu -i -p 'Action: ')" in
			'🔒 lock') slock ;;
			"🚪 leave dwm") kill -TERM "$(pidof dwm)" ;;
			"♻️ renew dwm") kill -HUP "$(pidof dwm)" ;;
			'🐻 hibernate') ${pkgs.systemd}/bin/systemctl hibernate -i ;;
			'💤 sleep') ${pkgs.systemd}/bin/systemctl suspend -i ;;
			'🔃 reboot') ${pkgs.systemd}/bin/systemctl reboot -i ;;
			'🖥️shutdown') ${pkgs.systemd}/bin/systemctl poweroff -i ;;
			'📺 display off') ${pkgs.xset}/bin/xset dpms force off ;;
			*) exit 1 ;;
		esac
		'';
	
	screenshotScript = pkgs.writeShellScriptBin "screenshot" ''
      #!/usr/bin/env sh
      output="$(date '+%y%m%d-%H%M-%S').png"
      xclip_img="${pkgs.xclip}/bin/xclip -sel clip -t image/png"
      xclip_txt="${pkgs.xclip}/bin/xclip -sel clip"

      case "$(printf "a selected area\\ncurrent window\\nfull screen\\na selected area (copy)\\ncurrent window (copy)\\nfull screen (copy)\\ncopy selected image to text" | ${pkgs.dmenu}/bin/dmenu -l 7 -i -p "Screenshot which area?") " in
        "a selected area") ${pkgs.maim}/bin/maim -u -s "pic-selected-$output" ;;
        "current window") ${pkgs.maim}/bin/maim -B -q -d 0.2 \ -i "$(${pkgs.xdotool}/bin/xdotool getactivewindow)" "pic-window-$output" ;;
        "full screen") ${pkgs.maim}/bin/maim -q -d 0.2 "pic-full-$output" ;;
        "a selected area (copy)") ${pkgs.maim}/bin/maim -u -s | $xclip_img ;;
        "current window (copy)") ${pkgs.maim}/bin/maim -q -d 0.2 \ -i "$(${pkgs.xdotool}/bin/xdotool getactivewindow)" | $xclip_img ;;
        "full screen (copy)") ${pkgs.maim}/bin/maim -q -d 0.2 | $xclip_img ;;
        "copy selected image to text")
          tmpfile="$(mktemp /tmp/ocr-XXXXXX.png)"
          ${pkgs.maim}/bin/maim -u -s > "$tmpfile"
          ${pkgs.tesseract}/bin/tesseract "$tmpfile" - -l eng | $xclip_txt
          rm -f "$tmpfile" ;;
      esac
'';
in
{
  environment.systemPackages = with pkgs;[
  	maim
  	screenshotScript
  	pwrMgrScript
  ];

  nixpkgs.overlays = [
		(self: super: {
    	dwm = super.dwm.overrideAttrs (oldAttrs: let
    	in{
      	src = builtins.path {
      		path = ./dwm;
      	};
      	buildInputs = oldAttrs.buildInputs ++ [ self.libxcb self.libxinerama];
      	postPatch = ''
      		cp config.my.h config.h
      	'';
      });
    }
    )
  ];
}
