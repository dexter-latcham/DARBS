{
  self,
  inputs,
  lib,
  ...
}: {
  perSystem = {pkgs, ...}: let
      configFile = pkgs.writeText "config.def.h" ''
        #ifndef CONFIG_H
        #define CONFIG_H
        #define DELIMITER "  "
        #define MAX_BLOCK_OUTPUT_LENGTH 100
        #define CLICKABLE_BLOCKS 1
        #define LEADING_DELIMITER 0
        #define TRAILING_DELIMITER 0
        #define BLOCKS(X)\
        X("", "date-test", 60, 0)
        #endif
      '';
  in
  {
    packages.dwmblocks = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.dwmblocks.overrideAttrs (oldAttrs:
        {
          src = pkgs.fetchFromGitHub {
            owner = "UtkarshVerma";
            repo = "dwmblocks-async";
            rev = "main";
            sha256 = "E3Jk+Cpcvo7/ePEdi09jInDB3JqLwN+ZHtutk3nmmhM=";
          };
          buildInputs = oldAttrs.buildInputs ++ [
            pkgs.libx11
            pkgs.pkg-config
            pkgs.libxcb
            pkgs.xcbutil
          ];
          postPatch = ''cp ${configFile} config.h '';
        }
      );
      runtimeInputs = [
      (pkgs.writeShellScriptBin "signal-dwmblocks" ''
        if [ -z "$1" ]; then
          exit 1
        fi
        signal=$((34+$1))
        ${pkgs.procps}/bin/pgrep dwmblocks | xargs -r kill -$signal
      '')
      (pkgs.writeShellApplication {
        name = "date-test";
        text = ''
          #!/bin/sh
          echo "^C13^$(date '+ %H:%M  %d-%m-%y')"
        '';
      })
      ];
    };
  };
}
