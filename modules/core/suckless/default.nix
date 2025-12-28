{ config, pkgs, lib, ... }:
let
  dwmblocksAsync = pkgs.stdenv.mkDerivation {
    pname = "dwmblocks";
    version = "1";

    src = pkgs.fetchFromGitHub {
      owner = "UtkarshVerma";
      repo = "dwmblocks-async";
      rev = "main"; # or a commit/tag
      hash = lib.fakeSha256; # leave blank, rebuild and fill
    };

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.libX11 pkgs.libxcb pkgs.xcbutil];

    makeFlags = [ "PREFIX=$(out)" ];

    meta.mainProgram = "dwmblocks";
  };

in
{
  imports = [./dwm.nix
  					./st.nix
  					./dmenu.nix];
  environment.systemPackages = with pkgs;[
  	dwmblocks
  ];
}
