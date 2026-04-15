{
  self,
  inputs,
  lib,
  ...
}: {
  perSystem = {pkgs, ...}: {
    packages.zathura = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.zathura;
      wrapper = { exePath, binName, ...}:''
      #!${pkgs.bash}/bin/bash
      echo "hello world"
      '';
    };
  };
}
