{
  config,
  pkgs,
  lib,
  username,
  ...
}: let
  mkStatusbarApp = {
    name,
    script,
    inputs ? [pkgs.coreutils],
  }:
    pkgs.writeShellApplication {
      inherit name;
      text = builtins.readFile script;
      runtimeInputs = inputs;
    };
  sb-date = mkStatusbarApp {
    name = "sb-date";
    script = ./statusbar/sb-date.sh;
  };
  sb-net = mkStatusbarApp {
    name = "sb-net";
    script = ./statusbar/sb-net.sh;
  };
  sb-bat = mkStatusbarApp {
    name = "sb-bat";
    script = ./statusbar/sb-bat.sh;
    inputs = [pkgs.coreutils pkgs.gawk pkgs.acpi pkgs.libnotify];
  };

  blocks = [
    {
      path = sb-net;
      interval = 0;
      signal = 2;
    }
    {
      path = sb-bat;
      interval = 600;
      signal = 1;
    }
    {
      path = sb-date;
      interval = 60;
      signal = 0;
    }
  ];

  configFile = pkgs.writeText "config.def.h" ''
    #ifndef CONFIG_H
    #define CONFIG_H

    // String used to delimit block outputs in the status.
    #define DELIMITER "  "

    // Maximum number of Unicode characters that a block can output.
    #define MAX_BLOCK_OUTPUT_LENGTH 100

    // Control whether blocks are clickable.
    #define CLICKABLE_BLOCKS 1

    // Control whether a leading delimiter should be prepended to the status.
    #define LEADING_DELIMITER 0

    // Control whether a trailing delimiter should be appended to the status.
    #define TRAILING_DELIMITER 0

    // Define blocks for the status feed as X(icon, cmd, interval, signal).
    #define BLOCKS(X)\
    ${lib.concatStringsSep "\\\n  " (map (b: ''X("", "${b.path}/bin/${b.path.name}", ${toString b.interval}, ${toString b.signal})'') blocks)}
    #endif
  '';
  dwmblocksAsync = pkgs.dwmblocks.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "UtkarshVerma";
      repo = "dwmblocks-async";
      rev = "main"; # or a commit/tag
      sha256 = "E3Jk+Cpcvo7/ePEdi09jInDB3JqLwN+ZHtutk3nmmhM=";
    };
    buildInputs = [
      pkgs.libx11
      pkgs.pkg-config
      pkgs.xorg.libxcb
      pkgs.xorg.xcbutil
    ];

    postPatch = ''cp ${configFile} config.h '';
  });
  signaldwmblocks = pkgs.writeShellScriptBin "signal-dwmblocks" ''
    if [ -z "$1" ]; then
      exit 1
    fi
    signal=$((34+$1))
    ${pkgs.procps}/bin/pgrep -u ${username} dwmblocks | xargs -r kill -$signal
  '';
in {
  environment.systemPackages = with pkgs; [
    dwmblocksAsync
    sb-date
    sb-bat
    sb-net
  ];

  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeText "sb-net-update" ''
        ${signaldwmblocks}/bin/signal-dwmblocks 2
      '';
      type = "basic";
    }
  ];
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", KERNEL=="BAT1", ATTR{capacity}!="", ACTION=="change", RUN+="${signaldwmblocks}/bin/signal-dwmblocks 1"
  '';
}
