{ config, pkgs, lib, ... }:
let
	batScript = pkgs.writeShellApplication {
	    name = "sb-bat";
	    text = builtins.readFile ./statusbar/sb-bat.sh;
	    runtimeInputs = with pkgs;[
	        coreutils
	        gawk
	        acpi
	        libnotify
	    ];
	};
  dwmblocksAsync = pkgs.dwmblocks.overrideAttrs(old: let
    configFile = pkgs.writeText "config.def.h" ''
#ifndef CONFIG_H
#define CONFIG_H

// String used to delimit block outputs in the status.
#define DELIMITER "  "

// Maximum number of Unicode characters that a block can output.
#define MAX_BLOCK_OUTPUT_LENGTH 45

// Control whether blocks are clickable.
#define CLICKABLE_BLOCKS 1

// Control whether a leading delimiter should be prepended to the status.
#define LEADING_DELIMITER 0

// Control whether a trailing delimiter should be appended to the status.
#define TRAILING_DELIMITER 0

// Define blocks for the status feed as X(icon, cmd, interval, signal).
#define BLOCKS(X)             \
    X("", "${batScript}/bin/sb-bat", 5, 9)

#endif  // CONFIG_H
    '';
    in {
    src = pkgs.fetchFromGitHub {
      owner = "UtkarshVerma";
      repo = "dwmblocks-async";
      rev = "main"; # or a commit/tag
      sha256 ="E3Jk+Cpcvo7/ePEdi09jInDB3JqLwN+ZHtutk3nmmhM=";
    };
    buildInputs = [ pkgs.libx11 
      pkgs.pkg-config
      pkgs.xorg.libxcb
      pkgs.xorg.xcbutil
    ];

    postPatch = ''
      cp ${configFile} config.h
    '';
  });
in
{
  environment.systemPackages = with pkgs;[
  	dwmblocksAsync
    batScript
  ];
}
