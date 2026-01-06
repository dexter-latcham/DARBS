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
      		keybindFile = super.writeText "keybinds.h" ''
	static const Key keys[] = {
		/* modifier                     key        function        argument */

		{ MODKEY,                       XK_Return, spawn,          SHCMD(TERMINAL)},
		{ MODKEY|ShiftMask,             XK_Return, togglescratch,  {.ui=0}},
		{ MODKEY|ShiftMask,             XK_i, 		 togglescratch,  {.ui=1}},
		{ MODKEY|ShiftMask,             XK_b, 		 togglescratch,  {.ui=2}},

		{ MODKEY,			          				XK_d,      spawn,          {.v = (const char*[]){ "dmenu_run", NULL } } },
  	{ MODKEY,                       XK_b,      spawn,          {.v = (const char*[]){ "${config.defaultBrowser}/bin/${config.defaultBrowser.name}", NULL } } },
		{ MODKEY|ShiftMask,		  				XK_s,	     spawn, 		     {.v = (const char*[]){ "${screenshotScript}/bin/screenshot", NULL } } },

		{ MODKEY,			          				XK_BackSpace,  spawn,      {.v = (const char*[]){ "${pwrMgrScript}/bin/pwrMgr", NULL } } },
		{ MODKEY|ShiftMask,		          XK_q,      spawn,          {.v = (const char*[]){ "${pwrMgrScript}/bin/pwrMgr", NULL } } },

		{ MODKEY,             					XK_f,      togglefullscr,  {0} },
		{ MODKEY,                       XK_q,      killclient,     {0} },

		{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
		{ MODKEY,                       XK_space,  zoom,      		 {0} },
		{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
		//{ MODKEY|ShiftMask,             XK_b,      togglebar,      {0} },

		{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
		{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },

		{ MODKEY,                       XK_o,      incnmaster,     {.i = +1 } },
		{ MODKEY|ShiftMask,             XK_o,      incnmaster,     {.i = -1 } },

		{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
		{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },

		{ MODKEY,                       XK_Tab,    view,           {0} },
		{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
		{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },

		{ MODKEY,                       XK_Left,  focusmon,       {.i = -1 } },
		{ MODKEY,                       XK_Right, focusmon,       {.i = +1 } },
		{ MODKEY|ShiftMask,             XK_Left,  tagmon,         {.i = -1 } },
		{ MODKEY|ShiftMask,             XK_Right, tagmon,         {.i = +1 } },

		{ MODKEY,                       XK_z,  	  incrgaps,       {.i = +1 } },
		{ MODKEY,                       XK_x,  	  incrgaps,       {.i = -1 } },
		{ MODKEY,                       XK_a,  	  togglegaps,     {0}},
		{ MODKEY|ShiftMask,             XK_a,  	  defaultgaps,    {0}},

		TAGKEYS(                        XK_1,                      0)
		TAGKEYS(                        XK_2,                      1)
		TAGKEYS(                        XK_3,                      2)
		TAGKEYS(                        XK_4,                      3)
		TAGKEYS(                        XK_5,                      4)
		TAGKEYS(                        XK_6,                      5)
		TAGKEYS(                        XK_7,                      6)
		TAGKEYS(                        XK_8,                      7)
		TAGKEYS(                        XK_9,                      8)

		//{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
	};
  	'';
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
