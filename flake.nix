{
  description = "Dexters nix config";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, ...}@inputs:
  let
      username = "dex";
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
  in
  {
    nixosConfigurations = {
      nixtop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [./hosts/laptop];
        specialArgs = {
            host = "nixtop";
            inherit self inputs username;
        };
      };
    };
  };
}
