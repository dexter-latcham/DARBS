{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    xorg.libX11
    xorg.libXinerama
    xorg.libXft
    fontconfig
    freetype
    pkg-config
    gnumake
    gcc
    libspng
  ];
}
