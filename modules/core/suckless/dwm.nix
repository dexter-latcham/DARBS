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
    		configFile = super.writeText "config.def.h" ''
/* See LICENSE file for copyright and license details. */

/* Constants */
#define TERMINAL "st"
#define TERMCLASS "St"

/* appearance */
static unsigned int borderpx  = 3;        /* border pixel of windows */
static unsigned int snap      = 32;       /* snap pixel */
static unsigned int gappih    = 20;       /* horiz inner gap between windows */
static unsigned int gappiv    = 10;       /* vert inner gap between windows */
static unsigned int gappoh    = 10;       /* horiz outer gap between windows and screen edge */
static unsigned int gappov    = 30;       /* vert outer gap between windows and screen edge */
static int swallowfloating    = 0;        /* 1 means swallow floating windows by default */
static int smartgaps          = 0;        /* 1 means no outer gap when there is only one window */
static int showbar            = 1;        /* 0 means no bar */
static const int vertpad            = 5;       /* vertical padding of bar */
static const int sidepad            = 5;       /* horizontal padding of bar */
static const unsigned int systraypinning = 0;   /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayonleft = 0;    /* 0: systray in the right corner, >0: systray on left of status text */
static const unsigned int systrayspacing = 2;   /* systray spacing */
static const int systraypinningfailfirst = 1;   /* 1: if pinning fails, display systray on the first monitor, False: display systray on the last monitor*/
static const int showsystray        = 1;        /* 0 means no systray */
static int topbar             = 1;        /* 0 means bottom bar */
static char *fonts[]          = { "monospace:size=15", "NotoColorEmoji:pixelsize=15:antialias=true:autohint=true"  };
static char normbgcolor[]           = "#222222";
static char normbordercolor[]       = "#444444";
static char normfgcolor[]           = "#bbbbbb";
static char selfgcolor[]            = "#eeeeee";
static char selbordercolor[]        = "#770000";
static char selbgcolor[]            = "#005577";
static char *colors[][3] = {
  /*               fg           bg           border   */
  [SchemeNorm] = { normfgcolor, normbgcolor, normbordercolor },
  [SchemeSel]  = { selfgcolor,  selbgcolor,  selbordercolor  },
};

typedef struct {
	const char *name;
	const void *cmd;
} Sp;

const char *spcmd1[] = {TERMINAL, "-n", "spterm", "-g", "120x34", NULL };

static Sp scratchpads[] = {
	/* name          cmd  */
	{"spterm",      spcmd1},
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	*/
	/* class    instance      title       	 tags mask    isfloating   isterminal  noswallow  monitor */
	{ "Gimp",     NULL,       NULL,          1 << 8,      0,           0,          0,         -1 },
	{ TERMCLASS,  NULL,       NULL,       	 0,           0,           1,          0,         -1 },
	{ NULL,       NULL,       "Event Tester", 0,          0,           0,          1,         -1 },
	{ TERMCLASS,  "floatterm", NULL,       	 0,           1,           1,          0,         -1 },
	{ TERMCLASS,  "bg",        NULL,       	 1 << 7,      0,           1,          0,         -1 },
	{ TERMCLASS,  "spterm",    NULL,       	 SPTAG(0),    1,           1,          0,         -1 },
	{ TERMCLASS,  "spcalc",    NULL,       	 SPTAG(1),    1,           1,          0,         -1 },
};

/* layout(s) */
static float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static int nmaster     = 1;    /* number of clients in master area */
static int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */
#define FORCE_VSPLIT 1  /* nrowgrid layout: force two clients to always split vertically */
#include "vanitygaps.c"
static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",	tile },	                /* Default: Master on left, slaves on right */
	{ "TTT",	bstack },               /* Master on top, slaves on bottom */

	{ "[@]",	spiral },               /* Fibonacci spiral */
	{ "[\\]",	dwindle },              /* Decreasing in size right and leftward */

	{ "[D]",	deck },	                /* Master on left, slaves in monocle-like mode on right */
	{ "[M]",	monocle },              /* All windows on top of eachother */

	{ "|M|",	centeredmaster },               /* Master in middle, slaves on sides */
	{ ">M>",	centeredfloatingmaster },       /* Same but master floats */

	{ "><>",	NULL },	                /* no layout function means floating behavior */
	{ NULL,		NULL },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },
#define STACKKEYS(MOD,ACTION) \
{ MOD,	XK_j,	ACTION##stack,	{.i = INC(+1) } }, \
{ MOD,	XK_k,	ACTION##stack,	{.i = INC(-1) } }, \
{ MOD,  XK_v,   ACTION##stack,  {.i = 0 } }, \
/* { MOD, XK_grave, ACTION##stack, {.i = PREVSEL } }, \ */
/* { MOD, XK_a,     ACTION##stack, {.i = 1 } }, \ */
/* { MOD, XK_z,     ACTION##stack, {.i = 2 } }, \ */
/* { MOD, XK_x,     ACTION##stack, {.i = -1 } }, */

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/*
 * Xresources preferences to load at startup
 */
ResourcePref resources[] = {
	{ "color0",		STRING,	&normbordercolor },
	{ "color8",		STRING,	&selbordercolor },
	{ "color0",		STRING,	&normbgcolor },
	{ "color4",		STRING,	&normfgcolor },
	{ "color0",		STRING,	&selfgcolor },
	{ "color4",		STRING,	&selbgcolor },
	{ "borderpx",		INTEGER, &borderpx },
	{ "snap",		INTEGER, &snap },
	{ "showbar",		INTEGER, &showbar },
	{ "topbar",		INTEGER, &topbar },
	{ "nmaster",		INTEGER, &nmaster },
	{ "resizehints",	INTEGER, &resizehints },
	{ "mfact",		FLOAT,	&mfact },
	{ "gappih",		INTEGER, &gappih },
	{ "gappiv",		INTEGER, &gappiv },
	{ "gappoh",		INTEGER, &gappoh },
	{ "gappov",		INTEGER, &gappov },
	{ "swallowfloating",	INTEGER, &swallowfloating },
	{ "smartgaps",		INTEGER, &smartgaps },
};

#include <X11/XF86keysym.h>
#include "shiftview.c"

static const Key keys[] = {
	/* modifier                     key            function                argument */
	STACKKEYS(MODKEY,                              focus)
	STACKKEYS(MODKEY|ShiftMask,                    push)
	TAGKEYS(			XK_1,          0)
	TAGKEYS(			XK_2,          1)
	TAGKEYS(			XK_3,          2)
	TAGKEYS(			XK_4,          3)
	TAGKEYS(			XK_5,          4)
	TAGKEYS(			XK_6,          5)
	TAGKEYS(			XK_7,          6)
	TAGKEYS(			XK_8,          7)
	TAGKEYS(			XK_9,          8)

	/*===============window manager keybinds=====================*/

	{ MODKEY,			          XK_0,	         view,                 {.ui = ~0 } },
	{ MODKEY|ShiftMask,		  XK_0,	         tag,                  {.ui = ~0 } },
	{ MODKEY,			          XK_Tab,        view,                 {0} },
	{ MODKEY,			          XK_o,          incnmaster,           {.i = +1 } },
	{ MODKEY|ShiftMask,		  XK_o,          incnmaster,           {.i = -1 } },
	{ MODKEY,			          XK_backslash,  view,                 {0} },
	{ MODKEY,			          XK_a,          togglegaps,           {0} },

	{ MODKEY,			          XK_f,          togglefullscr,        {0} },

	{ MODKEY,			          XK_h,          setmfact,             {.f = -0.05} },
	{ MODKEY,			          XK_l,          setmfact,             {.f = +0.05} },
	{ MODKEY,			          XK_Left,       focusmon,             {.i = -1 } },
	{ MODKEY|ShiftMask,		  XK_Left,       tagmon,               {.i = -1 } },
	{ MODKEY,			          XK_Right,      focusmon,             {.i = +1 } },
	{ MODKEY|ShiftMask,		  XK_Right,      tagmon,               {.i = +1 } },
	{ MODKEY,			          XK_space,      zoom,                 {0} },
	{ MODKEY|ShiftMask,		  XK_space,      togglefloating,       {0} },

	{ MODKEY|ShiftMask,		  XK_b,          togglebar,            {0} },

	/* keybinds for alternate layouts*/
	/*{ MODKEY,			XK_t,          setlayout,              {.v = &layouts[0]} }, */ /* tile */
	/*{ MODKEY|ShiftMask,		XK_t,          setlayout,              {.v = &layouts[1]} },*/  /* bstack */
	/*{ MODKEY,			XK_y,          setlayout,              {.v = &layouts[2]} },*/  /* spiral */
	/*{ MODKEY|ShiftMask,		XK_y,          setlayout,              {.v = &layouts[3]} },*/ /* dwindle */
	/*{ MODKEY,			XK_u,          setlayout,              {.v = &layouts[4]} },*/ /* deck */
	/*{ MODKEY|ShiftMask,		XK_u,          setlayout,              {.v = &layouts[5]} },*/ /* monocle */
	/*{ MODKEY,			XK_i,          setlayout,              {.v = &layouts[6]} },*/ /* centeredmaster */
	/*{ MODKEY|ShiftMask,		XK_i,          setlayout,              {.v = &layouts[7]} },*/ /* centeredfloatingmaster */
	/*{ MODKEY|ShiftMask,		XK_f,          setlayout,              {.v = &layouts[8]} },*/

	{ MODKEY,			          XK_q,          killclient,           {0} },


	/* app launcher*/
	{ MODKEY,			          XK_d,          spawn,                {.v = (const char*[]){ "dmenu_run", NULL } } },
	
	/*===============shell utilities=====================*/

	{ MODKEY|ShiftMask,		  XK_s,	         spawn, 		           {.v = (const char*[]){ "${screenshotScript}/bin/screenshot", NULL } } },
	{ 0,				            XK_Print,      spawn,                SHCMD("maim pic-full-$(date '+%y%m%d-%H%M-%S').png") },

	/* TODO emoji selection utility*/
	/*{ MODKEY,			XK_grave,      spawn,	               {.v = (const char*[]){ "dmenuunicode", NULL } } },*/

	/* TODO screen recording*/
	/*{ MODKEY,			XK_Print,      spawn,		       {.v = (const char*[]){ "dmenurecord", NULL } } },*/
	/*{ MODKEY|ShiftMask,		XK_Print,      spawn,                  {.v = (const char*[]){ "dmenurecord", "kill", NULL } } },*/
	/*{ MODKEY,			XK_Delete,     spawn,                  {.v = (const char*[]){ "dmenurecord", "kill", NULL } } },*/
	/*{ MODKEY,			XK_Scroll_Lock, spawn,                 SHCMD("killall screenkey || screenkey &") },*/

	/* login / power options */

	{ MODKEY,			          XK_BackSpace,  spawn,                {.v = (const char*[]){ "${pwrMgrScript}/bin/pwrMgr", NULL } } },
	{ MODKEY|ShiftMask,		  XK_q,          spawn,                {.v = (const char*[]){ "${pwrMgrScript}/bin/pwrMgr", NULL } } },


	/*===============application binds=====================*/
	/* terminal / scratchpad*/
	{ MODKEY,			          XK_Return,     spawn,                SHCMD(TERMINAL)},
	{ MODKEY|ShiftMask,	  	XK_Return,     togglescratch,        {.ui = 0} },

	/* browser*/
	{ MODKEY,			          XK_b,          spawn,                {.v = (const char*[]){ "${pkgs.librewolf}/bin/librewolf", NULL } } },

	/* file explorer*/
	{ MODKEY,			          XK_e,          spawn,                {.v = (const char*[]){ "thunar", NULL } } },

	/* network settings*/
	{ MODKEY|ShiftMask,		  XK_w,          spawn,                {.v = (const char*[]){ TERMINAL, "-e", "nmtui", NULL } } },

	/* htop*/
	{ MODKEY|ShiftMask,		  XK_r,          spawn,                {.v = (const char*[]){ TERMINAL, "-e", "htop", NULL } } },
};

/* TODO setup dwmblocks for bar*/
/* bar block settings */

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask           button          function        argument */
#ifndef __OpenBSD__
	  { ClkWinTitle,          0,                   Button2,        zoom,           {0} },
	{ ClkStatusText,        0,                   Button1,        sigdwmblocks,   {.i = 1} },
	{ ClkStatusText,        0,                   Button2,        sigdwmblocks,   {.i = 2} },
	{ ClkStatusText,        0,                   Button3,        sigdwmblocks,   {.i = 3} },
	{ ClkStatusText,        0,                   Button4,        sigdwmblocks,   {.i = 4} },
	{ ClkStatusText,        0,                   Button5,        sigdwmblocks,   {.i = 5} },
	{ ClkStatusText,        ShiftMask,           Button1,        sigdwmblocks,   {.i = 6} },
#endif
	{ ClkStatusText,        ShiftMask,           Button3,        spawn,          SHCMD(TERMINAL " -e nvim ~/.local/src/dwmblocks/config.h") },
	{ ClkClientWin,         MODKEY,              Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,              Button2,        defaultgaps,    {0} },
	{ ClkClientWin,         MODKEY,              Button3,        resizemouse,    {0} },
	{ ClkClientWin,		MODKEY,		     Button4,	     incrgaps,       {.i = +1} },
	{ ClkClientWin,		MODKEY,		     Button5,	     incrgaps,       {.i = -1} },
	{ ClkTagBar,            0,                   Button1,        view,           {0} },
	{ ClkTagBar,            0,                   Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,              Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,              Button3,        toggletag,      {0} },
	{ ClkTagBar,		0,		     Button4,	     shiftview,      {.i = -1} },
	{ ClkTagBar,		0,		     Button5,	     shiftview,      {.i = 1} },
	{ ClkRootWin,		0,		     Button2,	     togglebar,      {0} },
};
    		'';
    	in{
      	src = super.fetchFromGitHub {
					owner = "LukeSmithxyz";
					repo = "dwm";
					rev = "f570a251a00b286ac0aa11b8d4a1008edd172bd9";
					sha256 = "I+SPMquQGt5CTpV4hdjwo9hAQSBpH4IDCp0LL9ErEjQ=";
      	};
      	buildInputs = oldAttrs.buildInputs ++ [ self.libxcb self.libxinerama];
      	patches = [
					./assets/dwmSteam.diff
					./assets/systray.diff
      	];
      	postPatch = ''
      		cp ${configFile} config.h
      	'';
      });
    }
    )
  ];
}
