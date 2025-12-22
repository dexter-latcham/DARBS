{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ...}:
  let
    inherit (nixpkgs.lib) nixosSystem genAttrs replaceStrings;
    inherit (nixpkgs.lib.filesystem) packagesFromDirectoryRecursive listFilesRecursive;
    nameOf = path: replaceStrings [ ".nix" ] [ "" ] (baseNameOf (toString path));
  in
  {
    nixosModules = genAttrs (map nameOf (listFilesRecursive ./modules)) (
        name: import ./modules/${name}.nix
    );

    homeModules = genAttrs (map nameOf (listFilesRecursive ./home)) (name: import ./home/${name}.nix);

    overlays = genAttrs (map nameOf (listFilesRecursive ./overlays)) (
        name: import ./overlays/${name}.nix
    );

    nixosConfigurations.nixtop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs.myConfig=self;
      modules = listFilesRecursive ./me;
    };

    formatter = (pkgs: pkgs.nixfmt-rfc-style);
  };
}
