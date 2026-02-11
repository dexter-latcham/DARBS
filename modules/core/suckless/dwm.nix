{pkgs,inputs,  ...}: let
  pwrMgrScript = pkgs.writeShellApplication {
    name = "pwrMgr";
    runtimeInputs = [pkgs.systemd pkgs.xset];
    text = ''
        #!/usr/bin/env sh
      case "$(printf "🔒 lock\n🚪 leave dwm\n♻️ renew dwm\n🐻 hibernate\n🔃 reboot\n🖥️shutdown\n💤 sleep\n📺 display off" | dmenu -i -p 'Action: ')" in
      	'🔒 lock') slock ;;
      	"🚪 leave dwm") kill -TERM "$(pidof dwm)" ;;
      	"♻️ renew dwm") kill -HUP "$(pidof dwm)" ;;
      	'🐻 hibernate') systemctl hibernate -i ;;
      	'💤 sleep') systemctl suspend -i ;;
      	'🔃 reboot') systemctl reboot -i ;;
      	'🖥️shutdown') systemctl poweroff -i ;;
      	'📺 display off') xset dpms force off ;;
      	*) exit 1 ;;
      esac
    '';
  };

  screenshotScript = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = [pkgs.maim pkgs.xdotool pkgs.xclip pkgs.tesseract];
    text = ''
      #!/usr/bin/env sh
      output="$(date '+%y%m%d-%H%M-%S').png"
      xclip_img="xclip -sel clip -t image/png"
      xclip_txt="xclip -sel clip"

      case "$(printf "a selected area (copy)\ncurrent window (copy)\nfull screen (copy)\na selected area\ncurrent window\nfull screen\ncopy selected image to text" | dmenu -l 7 -i -p "Screenshot which area?")" in
      	"a selected area") maim -u -s "pic-selected-$output" ;;
      	"current window") maim -B -q -d 0.2 \ -i "$(xdotool getactivewindow)" "pic-window-$output" ;;
      	"full screen") maim -q -d 0.2 "pic-full-$output" ;;
      	"a selected area (copy)") maim -u -s | xclip -sel clip -t image/png ;;
      	"current window (copy)") maim -q -d 0.2 \ -i "$(xdotool getactivewindow)" | $xclip_img ;;
      	"full screen (copy)") maim -q -d 0.2 | $xclip_img ;;
      	"copy selected image to text")
      	tmpfile="$(mktemp /tmp/ocr-XXXXXX.png)"
      	maim -u -s > "$tmpfile"
      	tesseract "$tmpfile" - -l eng | $xclip_txt
      	rm -f "$tmpfile" ;;
      esac
    '';
  };
in {
  imports = [ inputs.dwm.nixosModules.default ];
  programs.dwm.enable = true;
  environment.systemPackages = with pkgs; [
    screenshotScript
  ];
  programs.dwm.appKeybinds = [
    {
      mod = "MODKEY|ShiftMask";
      key = "s";
      app = "${screenshotScript}/bin/screenshot";
    }
    {
      key = "BackSpace";
      app = "${pwrMgrScript}/bin/pwrMgr";
    }
    {
      mod = "MODKEY|ShiftMask";
      key = "q";
      app = "${pwrMgrScript}/bin/pwrMgr";
    }
  ];
}
