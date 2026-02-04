{
  description = "Dexters nix config";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    dwm.url = "github:dexter-latcham/dwm";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, disko, nixpkgs,dwm, stylix, ...}@inputs:
  let
      username = "dex";
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.cudaSupport = true;
      };
  in
  {
    nixosConfigurations = {
      nixtop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          dwm.nixosModules.default
          stylix.nixosModules.stylix
            ./hosts/laptop
          ];
        specialArgs = {
            host = "nixtop";
            inherit self inputs username;
        };
      };
    };
  };
}
