{ config, pkgs, lib, ... }:
let
  dwmblocksAsync = pkgs.stdenv.mkDerivation {
    pname = "dwmblocks";
    version = "1";

    src = pkgs.fetchFromGitHub {
      owner = "UtkarshVerma";
      repo = "dwmblocks-async";
      rev = "main"; # or a commit/tag
      hash = lib.fakeSha256; # leave blank, rebuild and fill
    };

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.libX11 pkgs.pkg-config ]
      ++ builtins.attrValues { inherit (pkgs.xorg) libxcb xcbutil; };

    makeFlags = [ "PREFIX=$(out)" ];

    meta.mainProgram = "dwmblocks";
  };

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
  	screenshotScript
  	pwrMgrScript
  	dwmblocks
  ];

  nixpkgs.overlays = [
  	( self: super: {
    st = super.st.overrideAttrs (oldAttrs: let
    configFile = super.writeText "config.def.h" ''
static char *font = "mono:pixelsize=12:antialias=true:autohint=true";
static char *font2[] = { "NotoColorEmoji:pixelsize=10:antialias=true:autohint=true" };
static int borderpx = 2;

/*
 * What program is execed by st depends of these precedence rules:
 * 1: program passed with -e
 * 2: scroll and/or utmp
 * 3: SHELL environment variable
 * 4: value of shell in /etc/passwd
 * 5: value of shell in config.h
 */
static char *shell = "/bin/sh";
char *utmp = NULL;
/* scroll program: to enable use a string like "scroll" */
char *scroll = NULL;
char *stty_args = "stty raw pass8 nl -echo -iexten -cstopb 38400";

/* identification sequence returned in DA and DECID */
char *vtiden = "\033[?6c";

/* Kerning / character bounding-box multipliers */
static float cwscale = 1.0;
static float chscale = 1.0;

wchar_t *worddelimiters = L" ";

/* selection timeouts (in milliseconds) */
static unsigned int doubleclicktimeout = 300;
static unsigned int tripleclicktimeout = 600;

/* alt screens */
int allowaltscreen = 1;

/* allow certain non-interactive (insecure) window operations such as:
   setting the clipboard text */
int allowwindowops = 0;

/*
 * draw latency range in ms - from new content/keypress/etc until drawing.
 * within this range, st draws when content stops arriving (idle). mostly it's
 * near minlatency, but it waits longer for slow updates to avoid partial draw.
 * low minlatency will tear/flicker more, as it can "detect" idle too early.
 */
static double minlatency = 8;
static double maxlatency = 33;

/*
 * blinking timeout (set to 0 to disable blinking) for the terminal blinking
 * attribute.
 */
static unsigned int blinktimeout = 800;

/*
 * thickness of underline and bar cursors
 */
static unsigned int cursorthickness = 2;

/*
 * 1: render most of the lines/blocks characters without using the font for
 *    perfect alignment between cells (U2500 - U259F except dashes/diagonals).
 *    Bold affects lines thickness if boxdraw_bold is not 0. Italic is ignored.
 * 0: disable (render all U25XX glyphs normally from the font).
 */
const int boxdraw = 1;
const int boxdraw_bold = 0;

/* braille (U28XX):  1: render as adjacent "pixels",  0: use font */
const int boxdraw_braille = 0;

/*
 * bell volume. It must be a value between -100 and 100. Use 0 for disabling
 * it
 */
static int bellvolume = 0;

/* default TERM value */
char *termname = "st-256color";

/*
 * spaces per tab
 *
 * When you are changing this value, don't forget to adapt the »it« value in
 * the st.info and appropriately install the st.info in the environment where
 * you use this st version.
 *
 *	it#$tabspaces,
 *
 * Secondly make sure your kernel is not expanding tabs. When running `stty
 * -a` »tab0« should appear. You can tell the terminal to not expand tabs by
 *  running following command:
 *
 *	stty tabs
 */
unsigned int tabspaces = 8;

/* bg opacity */
float alpha = 1;
float alphaOffset = 0.0;
float alphaUnfocus;

/* Terminal colors (16 first used in escape sequence) */
static const char *colorname[] = {
	"#282828", /* hard contrast: #1d2021 / soft contrast: #32302f */
	"#cc241d",
	"#98971a",
	"#d79921",
	"#458588",
	"#b16286",
	"#689d6a",
	"#a89984",
	"#928374",
	"#fb4934",
	"#b8bb26",
	"#fabd2f",
	"#83a598",
	"#d3869b",
	"#8ec07c",
	"#ebdbb2",
	[255] = 0,
	/* more colors can be added after 255 to use with DefaultXX */
	"#add8e6", /* 256 -> cursor */
	"#555555", /* 257 -> rev cursor*/
	"#282828", /* 258 -> bg */
	"#ebdbb2", /* 259 -> fg */
};


/*
 * Default colors (colorname index)
 * foreground, background, cursor, reverse cursor
 */
unsigned int defaultfg = 259;
unsigned int defaultbg = 258;
unsigned int defaultcs = 256;
unsigned int defaultrcs = 257;
unsigned int background = 258;

/*
 * Default shape of cursor
 * 2: Block ("█")
 * 4: Underline ("_")
 * 6: Bar ("|")
 * 7: Snowman ("☃")
 */
static unsigned int cursorshape = 2;

/*
 * Default columns and rows numbers
 */

static unsigned int cols = 80;
static unsigned int rows = 24;

/*
 * Default colour and shape of the mouse cursor
 */
static unsigned int mouseshape = XC_xterm;
static unsigned int mousefg = 7;
static unsigned int mousebg = 0;

/*
 * Color used to display font attributes when fontconfig selected a font which
 * doesn't match the ones requested.
 */
static unsigned int defaultattr = 11;

/*
 * Force mouse select/shortcuts while mask is active (when MODE_MOUSE is set).
 * Note that if you want to use ShiftMask with selmasks, set this to an other
 * modifier, set to 0 to not use it.
 */
static uint forcemousemod = ShiftMask;

/*
 * Xresources preferences to load at startup
 */
ResourcePref resources[] = {
		{ "font",         STRING,  &font },
		{ "fontalt0",     STRING,  &font2[0] },
		{ "color0",       STRING,  &colorname[0] },
		{ "color1",       STRING,  &colorname[1] },
		{ "color2",       STRING,  &colorname[2] },
		{ "color3",       STRING,  &colorname[3] },
		{ "color4",       STRING,  &colorname[4] },
		{ "color5",       STRING,  &colorname[5] },
		{ "color6",       STRING,  &colorname[6] },
		{ "color7",       STRING,  &colorname[7] },
		{ "color8",       STRING,  &colorname[8] },
		{ "color9",       STRING,  &colorname[9] },
		{ "color10",      STRING,  &colorname[10] },
		{ "color11",      STRING,  &colorname[11] },
		{ "color12",      STRING,  &colorname[12] },
		{ "color13",      STRING,  &colorname[13] },
		{ "color14",      STRING,  &colorname[14] },
		{ "color15",      STRING,  &colorname[15] },
		{ "background",   STRING,  &colorname[258] },
		{ "foreground",   STRING,  &colorname[259] },
		{ "cursorColor",  STRING,  &colorname[256] },
		{ "termname",     STRING,  &termname },
		{ "shell",        STRING,  &shell },
		{ "minlatency",   INTEGER, &minlatency },
		{ "maxlatency",   INTEGER, &maxlatency },
		{ "blinktimeout", INTEGER, &blinktimeout },
		{ "bellvolume",   INTEGER, &bellvolume },
		{ "tabspaces",    INTEGER, &tabspaces },
		{ "borderpx",     INTEGER, &borderpx },
		{ "cwscale",      FLOAT,   &cwscale },
		{ "chscale",      FLOAT,   &chscale },
		{ "alpha",        FLOAT,   &alpha },
		{ "alphaOffset",  FLOAT,   &alphaOffset },
};

/*
 * Internal mouse shortcuts.
 * Beware that overloading Button1 will disable the selection.
 */
static MouseShortcut mshortcuts[] = {
	/* mask                 button   function        argument       release */
	{ XK_NO_MOD,            Button4, kscrollup,      {.i = 1} },
	{ XK_NO_MOD,            Button5, kscrolldown,    {.i = 1} },
	{ XK_ANY_MOD,           Button2, selpaste,       {.i = 0},      1 },
	{ ShiftMask,            Button4, ttysend,        {.s = "\033[5;2~"} },
	{ XK_ANY_MOD,           Button4, ttysend,        {.s = "\031"} },
	{ ShiftMask,            Button5, ttysend,        {.s = "\033[6;2~"} },
	{ XK_ANY_MOD,           Button5, ttysend,        {.s = "\005"} },
};

/* Internal keyboard shortcuts. */
#define MODKEY Mod1Mask
#define TERMMOD (Mod1Mask|ShiftMask)

static char *openurlcmd[] = { "/bin/sh", "-c", "st-urlhandler -o", "externalpipe", NULL };
static char *copyurlcmd[] = { "/bin/sh", "-c", "st-urlhandler -c", "externalpipe", NULL };
static char *copyoutput[] = { "/bin/sh", "-c", "st-copyout", "externalpipe", NULL };

static Shortcut shortcuts[] = {
	/* mask                 keysym          function        argument */
	{ XK_ANY_MOD,           XK_Break,       sendbreak,      {.i =  0} },
	{ ControlMask,          XK_Print,       toggleprinter,  {.i =  0} },
	{ ShiftMask,            XK_Print,       printscreen,    {.i =  0} },
	{ XK_ANY_MOD,           XK_Print,       printsel,       {.i =  0} },
	{ TERMMOD,              XK_Prior,       zoom,           {.f = +1} },
	{ TERMMOD,              XK_Next,        zoom,           {.f = -1} },
	{ TERMMOD,              XK_Home,        zoomreset,      {.f =  0} },
	{ TERMMOD,              XK_C,           clipcopy,       {.i =  0} },
	{ TERMMOD,              XK_V,           clippaste,      {.i =  0} },
	{ MODKEY,               XK_c,           clipcopy,       {.i =  0} },
	{ ShiftMask,            XK_Insert,      clippaste,      {.i =  0} },
	{ MODKEY,               XK_v,           clippaste,      {.i =  0} },
	{ ShiftMask,            XK_Insert,      selpaste,       {.i =  0} },
	{ TERMMOD,              XK_Num_Lock,    numlock,        {.i =  0} },
	{ ShiftMask,            XK_Page_Up,     kscrollup,      {.i = -1} },
	{ ShiftMask,            XK_Page_Down,   kscrolldown,    {.i = -1} },
	{ MODKEY,               XK_Page_Up,     kscrollup,      {.i = -1} },
	{ MODKEY,               XK_Page_Down,   kscrolldown,    {.i = -1} },
	{ MODKEY,               XK_k,           kscrollup,      {.i =  1} },
	{ MODKEY,               XK_j,           kscrolldown,    {.i =  1} },
	{ MODKEY,               XK_Up,          kscrollup,      {.i =  1} },
	{ MODKEY,               XK_Down,        kscrolldown,    {.i =  1} },
	{ MODKEY,               XK_u,           kscrollup,      {.i = -1} },
	{ MODKEY,               XK_d,           kscrolldown,    {.i = -1} },
	{ MODKEY,		XK_s,		changealpha,	{.f = -0.05} },
	{ MODKEY,		XK_a,		changealpha,	{.f = +0.05} },
	{ TERMMOD,              XK_Up,          zoom,           {.f = +1} },
	{ TERMMOD,              XK_Down,        zoom,           {.f = -1} },
	{ TERMMOD,              XK_K,           zoom,           {.f = +1} },
	{ TERMMOD,              XK_J,           zoom,           {.f = -1} },
	{ TERMMOD,              XK_U,           zoom,           {.f = +2} },
	{ TERMMOD,              XK_D,           zoom,           {.f = -2} },
	{ MODKEY,               XK_l,           externalpipe,   {.v = openurlcmd } },
	{ MODKEY,               XK_y,           externalpipe,   {.v = copyurlcmd } },
	{ MODKEY,               XK_o,           externalpipe,   {.v = copyoutput } },
};

/*
 * Special keys (change & recompile st.info accordingly)
 *
 * Mask value:
 * * Use XK_ANY_MOD to match the key no matter modifiers state
 * * Use XK_NO_MOD to match the key alone (no modifiers)
 * appkey value:
 * * 0: no value
 * * > 0: keypad application mode enabled
 * *   = 2: term.numlock = 1
 * * < 0: keypad application mode disabled
 * appcursor value:
 * * 0: no value
 * * > 0: cursor application mode enabled
 * * < 0: cursor application mode disabled
 *
 * Be careful with the order of the definitions because st searches in
 * this table sequentially, so any XK_ANY_MOD must be in the last
 * position for a key.
 */

/*
 * If you want keys other than the X11 function keys (0xFD00 - 0xFFFF)
 * to be mapped below, add them to this array.
 */
static KeySym mappedkeys[] = { -1 };

/*
 * State bits to ignore when matching key or button events.  By default,
 * numlock (Mod2Mask) and keyboard layout (XK_SWITCH_MOD) are ignored.
 */
static uint ignoremod = Mod2Mask|XK_SWITCH_MOD;

/*
 * This is the huge key array which defines all compatibility to the Linux
 * world. Please decide about changes wisely.
 */
static Key key[] = {
	/* keysym           mask            string      appkey appcursor */
	{ XK_KP_Home,       ShiftMask,      "\033[2J",       0,   -1},
	{ XK_KP_Home,       ShiftMask,      "\033[1;2H",     0,   +1},
	{ XK_KP_Home,       XK_ANY_MOD,     "\033[H",        0,   -1},
	{ XK_KP_Home,       XK_ANY_MOD,     "\033[1~",       0,   +1},
	{ XK_KP_Up,         XK_ANY_MOD,     "\033Ox",       +1,    0},
	{ XK_KP_Up,         XK_ANY_MOD,     "\033[A",        0,   -1},
	{ XK_KP_Up,         XK_ANY_MOD,     "\033OA",        0,   +1},
	{ XK_KP_Down,       XK_ANY_MOD,     "\033Or",       +1,    0},
	{ XK_KP_Down,       XK_ANY_MOD,     "\033[B",        0,   -1},
	{ XK_KP_Down,       XK_ANY_MOD,     "\033OB",        0,   +1},
	{ XK_KP_Left,       XK_ANY_MOD,     "\033Ot",       +1,    0},
	{ XK_KP_Left,       XK_ANY_MOD,     "\033[D",        0,   -1},
	{ XK_KP_Left,       XK_ANY_MOD,     "\033OD",        0,   +1},
	{ XK_KP_Right,      XK_ANY_MOD,     "\033Ov",       +1,    0},
	{ XK_KP_Right,      XK_ANY_MOD,     "\033[C",        0,   -1},
	{ XK_KP_Right,      XK_ANY_MOD,     "\033OC",        0,   +1},
	{ XK_KP_Prior,      ShiftMask,      "\033[5;2~",     0,    0},
	{ XK_KP_Prior,      XK_ANY_MOD,     "\033[5~",       0,    0},
	{ XK_KP_Begin,      XK_ANY_MOD,     "\033[E",        0,    0},
	{ XK_KP_End,        ControlMask,    "\033[J",       -1,    0},
	{ XK_KP_End,        ControlMask,    "\033[1;5F",    +1,    0},
	{ XK_KP_End,        ShiftMask,      "\033[K",       -1,    0},
	{ XK_KP_End,        ShiftMask,      "\033[1;2F",    +1,    0},
	{ XK_KP_End,        XK_ANY_MOD,     "\033[4~",       0,    0},
	{ XK_KP_Next,       ShiftMask,      "\033[6;2~",     0,    0},
	{ XK_KP_Next,       XK_ANY_MOD,     "\033[6~",       0,    0},
	{ XK_KP_Insert,     ShiftMask,      "\033[2;2~",    +1,    0},
	{ XK_KP_Insert,     ShiftMask,      "\033[4l",      -1,    0},
	{ XK_KP_Insert,     ControlMask,    "\033[L",       -1,    0},
	{ XK_KP_Insert,     ControlMask,    "\033[2;5~",    +1,    0},
	{ XK_KP_Insert,     XK_ANY_MOD,     "\033[4h",      -1,    0},
	{ XK_KP_Insert,     XK_ANY_MOD,     "\033[2~",      +1,    0},
	{ XK_KP_Delete,     ControlMask,    "\033[M",       -1,    0},
	{ XK_KP_Delete,     ControlMask,    "\033[3;5~",    +1,    0},
	{ XK_KP_Delete,     ShiftMask,      "\033[2K",      -1,    0},
	{ XK_KP_Delete,     ShiftMask,      "\033[3;2~",    +1,    0},
	{ XK_KP_Delete,     XK_ANY_MOD,     "\033[P",       -1,    0},
	{ XK_KP_Delete,     XK_ANY_MOD,     "\033[3~",      +1,    0},
	{ XK_KP_Multiply,   XK_ANY_MOD,     "\033Oj",       +2,    0},
	{ XK_KP_Add,        XK_ANY_MOD,     "\033Ok",       +2,    0},
	{ XK_KP_Enter,      XK_ANY_MOD,     "\033OM",       +2,    0},
	{ XK_KP_Enter,      XK_ANY_MOD,     "\r",           -1,    0},
	{ XK_KP_Subtract,   XK_ANY_MOD,     "\033Om",       +2,    0},
	{ XK_KP_Decimal,    XK_ANY_MOD,     "\033On",       +2,    0},
	{ XK_KP_Divide,     XK_ANY_MOD,     "\033Oo",       +2,    0},
	{ XK_KP_0,          XK_ANY_MOD,     "\033Op",       +2,    0},
	{ XK_KP_1,          XK_ANY_MOD,     "\033Oq",       +2,    0},
	{ XK_KP_2,          XK_ANY_MOD,     "\033Or",       +2,    0},
	{ XK_KP_3,          XK_ANY_MOD,     "\033Os",       +2,    0},
	{ XK_KP_4,          XK_ANY_MOD,     "\033Ot",       +2,    0},
	{ XK_KP_5,          XK_ANY_MOD,     "\033Ou",       +2,    0},
	{ XK_KP_6,          XK_ANY_MOD,     "\033Ov",       +2,    0},
	{ XK_KP_7,          XK_ANY_MOD,     "\033Ow",       +2,    0},
	{ XK_KP_8,          XK_ANY_MOD,     "\033Ox",       +2,    0},
	{ XK_KP_9,          XK_ANY_MOD,     "\033Oy",       +2,    0},
	{ XK_Up,            ShiftMask,      "\033[1;2A",     0,    0},
	{ XK_Up,            Mod1Mask,       "\033[1;3A",     0,    0},
	{ XK_Up,         ShiftMask|Mod1Mask,"\033[1;4A",     0,    0},
	{ XK_Up,            ControlMask,    "\033[1;5A",     0,    0},
	{ XK_Up,      ShiftMask|ControlMask,"\033[1;6A",     0,    0},
	{ XK_Up,       ControlMask|Mod1Mask,"\033[1;7A",     0,    0},
	{ XK_Up,ShiftMask|ControlMask|Mod1Mask,"\033[1;8A",  0,    0},
	{ XK_Up,            XK_ANY_MOD,     "\033[A",        0,   -1},
	{ XK_Up,            XK_ANY_MOD,     "\033OA",        0,   +1},
	{ XK_Down,          ShiftMask,      "\033[1;2B",     0,    0},
	{ XK_Down,          Mod1Mask,       "\033[1;3B",     0,    0},
	{ XK_Down,       ShiftMask|Mod1Mask,"\033[1;4B",     0,    0},
	{ XK_Down,          ControlMask,    "\033[1;5B",     0,    0},
	{ XK_Down,    ShiftMask|ControlMask,"\033[1;6B",     0,    0},
	{ XK_Down,     ControlMask|Mod1Mask,"\033[1;7B",     0,    0},
	{ XK_Down,ShiftMask|ControlMask|Mod1Mask,"\033[1;8B",0,    0},
	{ XK_Down,          XK_ANY_MOD,     "\033[B",        0,   -1},
	{ XK_Down,          XK_ANY_MOD,     "\033OB",        0,   +1},
	{ XK_Left,          ShiftMask,      "\033[1;2D",     0,    0},
	{ XK_Left,          Mod1Mask,       "\033[1;3D",     0,    0},
	{ XK_Left,       ShiftMask|Mod1Mask,"\033[1;4D",     0,    0},
	{ XK_Left,          ControlMask,    "\033[1;5D",     0,    0},
	{ XK_Left,    ShiftMask|ControlMask,"\033[1;6D",     0,    0},
	{ XK_Left,     ControlMask|Mod1Mask,"\033[1;7D",     0,    0},
	{ XK_Left,ShiftMask|ControlMask|Mod1Mask,"\033[1;8D",0,    0},
	{ XK_Left,          XK_ANY_MOD,     "\033[D",        0,   -1},
	{ XK_Left,          XK_ANY_MOD,     "\033OD",        0,   +1},
	{ XK_Right,         ShiftMask,      "\033[1;2C",     0,    0},
	{ XK_Right,         Mod1Mask,       "\033[1;3C",     0,    0},
	{ XK_Right,      ShiftMask|Mod1Mask,"\033[1;4C",     0,    0},
	{ XK_Right,         ControlMask,    "\033[1;5C",     0,    0},
	{ XK_Right,   ShiftMask|ControlMask,"\033[1;6C",     0,    0},
	{ XK_Right,    ControlMask|Mod1Mask,"\033[1;7C",     0,    0},
	{ XK_Right,ShiftMask|ControlMask|Mod1Mask,"\033[1;8C",0,   0},
	{ XK_Right,         XK_ANY_MOD,     "\033[C",        0,   -1},
	{ XK_Right,         XK_ANY_MOD,     "\033OC",        0,   +1},
	{ XK_ISO_Left_Tab,  ShiftMask,      "\033[Z",        0,    0},
	{ XK_Return,        Mod1Mask,       "\033\r",        0,    0},
	{ XK_Return,        XK_ANY_MOD,     "\r",            0,    0},
	{ XK_Insert,        ShiftMask,      "\033[4l",      -1,    0},
	{ XK_Insert,        ShiftMask,      "\033[2;2~",    +1,    0},
	{ XK_Insert,        ControlMask,    "\033[L",       -1,    0},
	{ XK_Insert,        ControlMask,    "\033[2;5~",    +1,    0},
	{ XK_Insert,        XK_ANY_MOD,     "\033[4h",      -1,    0},
	{ XK_Insert,        XK_ANY_MOD,     "\033[2~",      +1,    0},
	{ XK_Delete,        ControlMask,    "\033[M",       -1,    0},
	{ XK_Delete,        ControlMask,    "\033[3;5~",    +1,    0},
	{ XK_Delete,        ShiftMask,      "\033[2K",      -1,    0},
	{ XK_Delete,        ShiftMask,      "\033[3;2~",    +1,    0},
	{ XK_Delete,        XK_ANY_MOD,     "\033[P",       -1,    0},
	{ XK_Delete,        XK_ANY_MOD,     "\033[3~",      +1,    0},
	{ XK_BackSpace,     XK_NO_MOD,      "\177",          0,    0},
	{ XK_BackSpace,     Mod1Mask,       "\033\177",      0,    0},
	{ XK_Home,          ShiftMask,      "\033[2J",       0,   -1},
	{ XK_Home,          ShiftMask,      "\033[1;2H",     0,   +1},
	{ XK_Home,          XK_ANY_MOD,     "\033[H",        0,   -1},
	{ XK_Home,          XK_ANY_MOD,     "\033[1~",       0,   +1},
	{ XK_End,           ControlMask,    "\033[J",       -1,    0},
	{ XK_End,           ControlMask,    "\033[1;5F",    +1,    0},
	{ XK_End,           ShiftMask,      "\033[K",       -1,    0},
	{ XK_End,           ShiftMask,      "\033[1;2F",    +1,    0},
	{ XK_End,           XK_ANY_MOD,     "\033[4~",       0,    0},
	{ XK_Prior,         ControlMask,    "\033[5;5~",     0,    0},
	{ XK_Prior,         ShiftMask,      "\033[5;2~",     0,    0},
	{ XK_Prior,         XK_ANY_MOD,     "\033[5~",       0,    0},
	{ XK_Next,          ControlMask,    "\033[6;5~",     0,    0},
	{ XK_Next,          ShiftMask,      "\033[6;2~",     0,    0},
	{ XK_Next,          XK_ANY_MOD,     "\033[6~",       0,    0},
	{ XK_F1,            XK_NO_MOD,      "\033OP" ,       0,    0},
	{ XK_F1, /* F13 */  ShiftMask,      "\033[1;2P",     0,    0},
	{ XK_F1, /* F25 */  ControlMask,    "\033[1;5P",     0,    0},
	{ XK_F1, /* F37 */  Mod4Mask,       "\033[1;6P",     0,    0},
	{ XK_F1, /* F49 */  Mod1Mask,       "\033[1;3P",     0,    0},
	{ XK_F1, /* F61 */  Mod3Mask,       "\033[1;4P",     0,    0},
	{ XK_F2,            XK_NO_MOD,      "\033OQ" ,       0,    0},
	{ XK_F2, /* F14 */  ShiftMask,      "\033[1;2Q",     0,    0},
	{ XK_F2, /* F26 */  ControlMask,    "\033[1;5Q",     0,    0},
	{ XK_F2, /* F38 */  Mod4Mask,       "\033[1;6Q",     0,    0},
	{ XK_F2, /* F50 */  Mod1Mask,       "\033[1;3Q",     0,    0},
	{ XK_F2, /* F62 */  Mod3Mask,       "\033[1;4Q",     0,    0},
	{ XK_F3,            XK_NO_MOD,      "\033OR" ,       0,    0},
	{ XK_F3, /* F15 */  ShiftMask,      "\033[1;2R",     0,    0},
	{ XK_F3, /* F27 */  ControlMask,    "\033[1;5R",     0,    0},
	{ XK_F3, /* F39 */  Mod4Mask,       "\033[1;6R",     0,    0},
	{ XK_F3, /* F51 */  Mod1Mask,       "\033[1;3R",     0,    0},
	{ XK_F3, /* F63 */  Mod3Mask,       "\033[1;4R",     0,    0},
	{ XK_F4,            XK_NO_MOD,      "\033OS" ,       0,    0},
	{ XK_F4, /* F16 */  ShiftMask,      "\033[1;2S",     0,    0},
	{ XK_F4, /* F28 */  ControlMask,    "\033[1;5S",     0,    0},
	{ XK_F4, /* F40 */  Mod4Mask,       "\033[1;6S",     0,    0},
	{ XK_F4, /* F52 */  Mod1Mask,       "\033[1;3S",     0,    0},
	{ XK_F5,            XK_NO_MOD,      "\033[15~",      0,    0},
	{ XK_F5, /* F17 */  ShiftMask,      "\033[15;2~",    0,    0},
	{ XK_F5, /* F29 */  ControlMask,    "\033[15;5~",    0,    0},
	{ XK_F5, /* F41 */  Mod4Mask,       "\033[15;6~",    0,    0},
	{ XK_F5, /* F53 */  Mod1Mask,       "\033[15;3~",    0,    0},
	{ XK_F6,            XK_NO_MOD,      "\033[17~",      0,    0},
	{ XK_F6, /* F18 */  ShiftMask,      "\033[17;2~",    0,    0},
	{ XK_F6, /* F30 */  ControlMask,    "\033[17;5~",    0,    0},
	{ XK_F6, /* F42 */  Mod4Mask,       "\033[17;6~",    0,    0},
	{ XK_F6, /* F54 */  Mod1Mask,       "\033[17;3~",    0,    0},
	{ XK_F7,            XK_NO_MOD,      "\033[18~",      0,    0},
	{ XK_F7, /* F19 */  ShiftMask,      "\033[18;2~",    0,    0},
	{ XK_F7, /* F31 */  ControlMask,    "\033[18;5~",    0,    0},
	{ XK_F7, /* F43 */  Mod4Mask,       "\033[18;6~",    0,    0},
	{ XK_F7, /* F55 */  Mod1Mask,       "\033[18;3~",    0,    0},
	{ XK_F8,            XK_NO_MOD,      "\033[19~",      0,    0},
	{ XK_F8, /* F20 */  ShiftMask,      "\033[19;2~",    0,    0},
	{ XK_F8, /* F32 */  ControlMask,    "\033[19;5~",    0,    0},
	{ XK_F8, /* F44 */  Mod4Mask,       "\033[19;6~",    0,    0},
	{ XK_F8, /* F56 */  Mod1Mask,       "\033[19;3~",    0,    0},
	{ XK_F9,            XK_NO_MOD,      "\033[20~",      0,    0},
	{ XK_F9, /* F21 */  ShiftMask,      "\033[20;2~",    0,    0},
	{ XK_F9, /* F33 */  ControlMask,    "\033[20;5~",    0,    0},
	{ XK_F9, /* F45 */  Mod4Mask,       "\033[20;6~",    0,    0},
	{ XK_F9, /* F57 */  Mod1Mask,       "\033[20;3~",    0,    0},
	{ XK_F10,           XK_NO_MOD,      "\033[21~",      0,    0},
	{ XK_F10, /* F22 */ ShiftMask,      "\033[21;2~",    0,    0},
	{ XK_F10, /* F34 */ ControlMask,    "\033[21;5~",    0,    0},
	{ XK_F10, /* F46 */ Mod4Mask,       "\033[21;6~",    0,    0},
	{ XK_F10, /* F58 */ Mod1Mask,       "\033[21;3~",    0,    0},
	{ XK_F11,           XK_NO_MOD,      "\033[23~",      0,    0},
	{ XK_F11, /* F23 */ ShiftMask,      "\033[23;2~",    0,    0},
	{ XK_F11, /* F35 */ ControlMask,    "\033[23;5~",    0,    0},
	{ XK_F11, /* F47 */ Mod4Mask,       "\033[23;6~",    0,    0},
	{ XK_F11, /* F59 */ Mod1Mask,       "\033[23;3~",    0,    0},
	{ XK_F12,           XK_NO_MOD,      "\033[24~",      0,    0},
	{ XK_F12, /* F24 */ ShiftMask,      "\033[24;2~",    0,    0},
	{ XK_F12, /* F36 */ ControlMask,    "\033[24;5~",    0,    0},
	{ XK_F12, /* F48 */ Mod4Mask,       "\033[24;6~",    0,    0},
	{ XK_F12, /* F60 */ Mod1Mask,       "\033[24;3~",    0,    0},
	{ XK_F13,           XK_NO_MOD,      "\033[1;2P",     0,    0},
	{ XK_F14,           XK_NO_MOD,      "\033[1;2Q",     0,    0},
	{ XK_F15,           XK_NO_MOD,      "\033[1;2R",     0,    0},
	{ XK_F16,           XK_NO_MOD,      "\033[1;2S",     0,    0},
	{ XK_F17,           XK_NO_MOD,      "\033[15;2~",    0,    0},
	{ XK_F18,           XK_NO_MOD,      "\033[17;2~",    0,    0},
	{ XK_F19,           XK_NO_MOD,      "\033[18;2~",    0,    0},
	{ XK_F20,           XK_NO_MOD,      "\033[19;2~",    0,    0},
	{ XK_F21,           XK_NO_MOD,      "\033[20;2~",    0,    0},
	{ XK_F22,           XK_NO_MOD,      "\033[21;2~",    0,    0},
	{ XK_F23,           XK_NO_MOD,      "\033[23;2~",    0,    0},
	{ XK_F24,           XK_NO_MOD,      "\033[24;2~",    0,    0},
	{ XK_F25,           XK_NO_MOD,      "\033[1;5P",     0,    0},
	{ XK_F26,           XK_NO_MOD,      "\033[1;5Q",     0,    0},
	{ XK_F27,           XK_NO_MOD,      "\033[1;5R",     0,    0},
	{ XK_F28,           XK_NO_MOD,      "\033[1;5S",     0,    0},
	{ XK_F29,           XK_NO_MOD,      "\033[15;5~",    0,    0},
	{ XK_F30,           XK_NO_MOD,      "\033[17;5~",    0,    0},
	{ XK_F31,           XK_NO_MOD,      "\033[18;5~",    0,    0},
	{ XK_F32,           XK_NO_MOD,      "\033[19;5~",    0,    0},
	{ XK_F33,           XK_NO_MOD,      "\033[20;5~",    0,    0},
	{ XK_F34,           XK_NO_MOD,      "\033[21;5~",    0,    0},
	{ XK_F35,           XK_NO_MOD,      "\033[23;5~",    0,    0},
};

/*
 * Selection types' masks.
 * Use the same masks as usual.
 * Button1Mask is always unset, to make masks match between ButtonPress.
 * ButtonRelease and MotionNotify.
 * If no match is found, regular selection is used.
 */
static uint selmasks[] = {
	[SEL_RECTANGULAR] = Mod1Mask,
};

/*
 * Printable characters in ASCII, used to estimate the advance width
 * of single wide characters.
 */
static char ascii_printable[] =
	" !\"#$%&'()*+,-./0123456789:;<=>?"
	"@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_"
	"`abcdefghijklmnopqrstuvwxyz{|}~";

    '';
    in{
      src = super.fetchFromGitHub {
	owner = "LukeSmithxyz";
	repo = "st";
	rev = "62ebf677d3ad79e0596ff610127df5db034cd234";
	sha256 = "L4FKnK4k2oImuRxlapQckydpAAyivwASeJixTj+iFrM=";
      };
      buildInputs = oldAttrs.buildInputs ++ [ self.harfbuzz ];
      postPatch = ''
      	cp ${configFile} config.h
      '';
      });
    })
		(self: super: {
    	dmenu = super.dmenu.overrideAttrs (oldAttrs: let
    		configFile = super.writeText "config.def.h" ''
     static int topbar = 1;                      /* -b  option; if 0, dmenu appears at bottom     */
		 static int centered = 1;                    /* -c option; centers dmenu on screen */
		 static int min_width = 500;                    /* minimum width when centered */
		 static int fuzzy =1;
		 static const float menu_height_ratio = 4.0f;  /* This is the ratio used in the original calculation */
     static const char *fonts[] = { "monospace:size=10" };
     static const char *prompt      = NULL;      /* -p  option; prompt to the left of input field */
     static const char *colors[SchemeLast][2] = {
     	[SchemeNorm] = { "#bbbbbb", "#222222" },
     	[SchemeSel] = { "#eeeeee", "#005577" },
     	[SchemeOut] = { "#000000", "#00ffff" },
     };

     static unsigned int lines      = 10;
     static const char worddelimiters[] = " ";
    			'';
    	in{
      	patches = [
    			(super.fetchpatch{
    				url = "https://tools.suckless.org/dmenu/patches/sort_by_popularity/dmenu-sort_by_popularity-20250117-86f0b51.diff";
    				sha256="019aaix8aiyg646qvvmq93zz60xh1a92lr9znkz6qhgfigg64xdi";
    			})
    			(super.fetchpatch{
    				url = "https://tools.suckless.org/dmenu/patches/fuzzymatch/dmenu-fuzzymatch-5.3.diff";
    				sha256="0f4a3sfpcgqy751kgpqlvvj1sybjfa798g2rynl9cdng08kca6vm";
    			})
    			(super.fetchpatch{
    				url = "https://tools.suckless.org/dmenu/patches/mouse-support/dmenu-mousesupport-5.4.diff";
    				sha256="13c9i4p8zdpw5fx3c1051had9xh13fs2ix5f7cb3hbm5xwqdvcjj";
    			})

    			(super.fetchpatch{
    				url = "https://tools.suckless.org/dmenu/patches/xresources/dmenu-xresources-4.9.diff";
    				sha256="1mk3zgk43ilcy184jhmr3hxw9pjbnzhba3hifrk3k7wmdki89f3m";
    			})
    			./suckless/assets/dmenuCenter.diff
      	];
      	postPatch = ''
      		cp ${configFile} config.h
      	'';
      });
    })
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
					./suckless/assets/dwmSteam.diff
					./suckless/assets/systray.diff
      	];
      	postPatch = ''
      		cp ${configFile} config.h
      	'';
      });
    }
    )
  ];
}
