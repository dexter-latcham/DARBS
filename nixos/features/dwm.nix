{inputs,self, ...}: {
  flake.nixosModules.dwm = {pkgs, ...}: let
    selfpkgs = self.packages."${pkgs.system}";
  in {
    imports = [
      inputs.dwm.nixosModules.default
    ];

    environment.systemPackages = [
    ];
  };
}
