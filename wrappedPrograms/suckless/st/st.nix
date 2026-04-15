{
  self,
  inputs,
  lib,
  ...
}: {
  perSystem = {pkgs, ...}: {
    packages.st = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      # flags = {
      #   "-e" = lib.getExe pkgs.bash;
      # };

      package = pkgs.st.overrideAttrs (oldAttrs:
        {
          src = pkgs.fetchFromGitHub {
            owner = "LukeSmithxyz";
            repo = "st";
            rev = "62ebf677d3ad79e0596ff610127df5db034cd234";
            sha256 = "L4FKnK4k2oImuRxlapQckydpAAyivwASeJixTj+iFrM=";
          };
          buildInputs = oldAttrs.buildInputs ++ [pkgs.harfbuzz];
        }
      );
    };
  };
}
