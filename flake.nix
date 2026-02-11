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
      # inputs.nixpkgs.follows = "nixpkgs";

    };

    impermanence = {
      url = "github:nix-community/impermanence";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:FlameFlag/nixcord";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-auto-follow = {
      url = "github:fzakaria/nix-auto-follow";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    username = "dex";
    system = "x86_64-linux";
    host = "nixtop";
  in {
    nixosConfigurations = {
      nixtop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/laptop
        ];
        specialArgs = {
          inherit self inputs username host;
        };
      };
    };
  };
}
