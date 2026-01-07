{ config, pkgs, lib, ... }:
let
	pwrMgrScript = pkgs.writeShellApplication {
		name = "pwrMgr";
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
		runtimeInputs = [pkgs.systemd pkgs.xset];
	};
	
	screenshotScript = pkgs.writeShellApplication{
		name = "screenshot";
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
		runtimeInputs = [pkgs.maim pkgs.xdotool pkgs.xclip pkgs.tesseract];
	};
  defaultMod = "MODKEY";
  modShift = "MODKEY|ShiftMask";

	mkKey = { key, fun, arg ? "{0}", mod ? defaultMod}: {
  	inherit mod key fun arg;
	};

spawnArg = cmd:
  "{.v = (const char*[]){ \"${cmd}\", NULL }}";

spawnKey = {
  key,
  cmd,
  mod ? defaultMod,
}: mkKey {
  inherit key mod;
  fun = "spawn";
  arg = spawnArg cmd;
};
  argI  = i: "{.i = ${i}}";
  argF  = f: "{.f = ${f}}";
  argUI = ui: "{.ui = ${ui}}";

  keyToC = k: "{ ${k.mod}, ${k.key}, ${k.fun}, ${k.arg} },";

	keybindsC = lib.concatStringsSep "\n  " (map keyToC keybinds);

	keybinds = [
		(mkKey { key = "XK_Return"; fun = "spawn"; arg = "SHCMD(TERMINAL)"; })
		(mkKey { mod=modShift; key = "XK_Return"; fun = "togglescratch"; arg = argUI "0"; })
		(mkKey { mod=modShift; key = "XK_i"; fun = "togglescratch"; arg = argUI "1" ; })
		(mkKey { mod=modShift; key = "XK_b"; fun = "togglescratch"; arg = argUI "2"; })
		(spawnKey {key = "XK_d"; cmd = "dmenu_run"; })
		(spawnKey {key = "XK_b"; cmd = "${config.defaultBrowser}/bin/${config.defaultBrowser.name}"; })
		(spawnKey {mod = modShift; key = "XK_s"; cmd = "${screenshotScript}/bin/screenshot"; })
		(spawnKey {key = "XK_BackSpace"; cmd = "${pwrMgrScript}/bin/pwrMgr"; })
		(spawnKey {mod = modShift; key = "XK_q"; cmd = "${pwrMgrScript}/bin/pwrMgr"; })
		(mkKey { key = "XK_f"; fun = "togglefullscr"; })
		(mkKey { key = "XK_q"; fun = "killclient"; })
		(mkKey { key = "XK_t"; fun = "setlayout"; arg="{.v = &layouts[0]}"; })
		(mkKey { key = "XK_space"; fun = "zoom"; })
		(mkKey { mod = modShift; key = "XK_space"; fun = "togglefloating"; })
		(mkKey { mod = modShift; key = "XK_x"; fun = "togglebar"; })
		(mkKey { key = "XK_j"; fun = "focusstack"; arg = argI "+1"; })
		(mkKey { key = "XK_k"; fun = "focusstack"; arg = argI "-1"; })
		(mkKey { key = "XK_o"; fun = "incnmaster"; arg = argI "+1"; })
		(mkKey { mod = modShift; key = "XK_o"; fun = "incnmaster"; arg = argI "-1"; })

		(mkKey { key = "XK_h"; fun = "setmfact"; arg = argF "-0.05"; })
		(mkKey { key = "XK_l"; fun = "setmfact"; arg = argF "+0.05"; })

		(mkKey { key = "XK_Tab"; fun = "view"; })
		(mkKey { key = "XK_0"; fun = "view"; arg = argUI "~0"; })
		(mkKey { mod = modShift; key = "XK_0"; fun = "tag"; arg = argUI "~0"; })


		(mkKey { key = "XK_Left"; fun = "focusmon"; arg = argI "-1"; })
		(mkKey { key = "XK_Right"; fun = "focusmon"; arg = argI "+1"; })

		(mkKey { mod=modShift; key = "XK_Left"; fun = "tagmon"; arg = argI "-1"; })
		(mkKey { mod=modShift; key = "XK_Right"; fun = "tagmon"; arg = argI "+1"; })

		(mkKey { key = "XK_z"; fun = "incrgaps"; arg = argI "+1"; })
		(mkKey { key = "XK_x"; fun = "incrgaps"; arg = argI "-1"; })

		(mkKey { key = "XK_a"; fun = "togglegaps"; })
		(mkKey { mod=modShift; key = "XK_a"; fun = "defaultgaps"; })
	];

# helper: count how many times 'x' appears in a list
count = list: x: builtins.length (builtins.filter (y: y == x) list);

# mod+key strings
modKeyStrings = map (k: "${k.mod}+${k.key}") keybinds;

# duplicates: strings appearing more than once
duplicates = lib.filter (x: count modKeyStrings x > 1) modKeyStrings;
in
if duplicates != [] then
  throw "Duplicate keybinds detected for: ${lib.concatStringsSep ", " duplicates}"
else
	let


  keybindsH = ''
    static const Key keys[] = {
      /* modifier                     key        function        argument */
      ${keybindsC}
		TAGKEYS(                        XK_1,                      0)
		TAGKEYS(                        XK_2,                      1)
		TAGKEYS(                        XK_3,                      2)
		TAGKEYS(                        XK_4,                      3)
		TAGKEYS(                        XK_5,                      4)
		TAGKEYS(                        XK_6,                      5)
		TAGKEYS(                        XK_7,                      6)
		TAGKEYS(                        XK_8,                      7)
		TAGKEYS(                        XK_9,                      8)
    };
  '';
	keybindFile = pkgs.writeText "keybinds.h" keybindsH;
in
{
  options.defaultBrowser= lib.mkOption {
  	type = lib.types.package;
  	default = pkgs.librewolf;
  };
  config = {
  	nixpkgs.overlays = [
			(self: super: {
    		dwm = super.dwm.overrideAttrs (oldAttrs: let
    		in{
      		src = builtins.path {
      			path = ./dwm;
      		};
      		buildInputs = oldAttrs.buildInputs ++ [ self.libxcb self.libxinerama self.imlib2];
      		postPatch = ''
      			cp config.my.h config.h
      			cp ${keybindFile} keybinds.h
      		'';
      	});
    	}
    )
  	];
	};
}
