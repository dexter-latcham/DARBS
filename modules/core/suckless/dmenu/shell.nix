{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "dmenu-build-shell";

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

  shellHook = ''
    echo "dmenu build environment ready"
  '';
}
