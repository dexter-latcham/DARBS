{ config, pkgs, lib, ... }:
{
  nixpkgs.overlays = [
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
    			./assets/dmenuCenter.diff
      	];
      	postPatch = ''
      		cp ${configFile} config.h
      	'';
      });
    })
  ];
}
