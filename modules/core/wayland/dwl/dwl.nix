{pkgs,...}:{
  nixpkgs.overlays = with pkgs;[
    (final: prev:{
      dwl = prev.dwl.overrideAttrs(oldAttrs: {
        src = builtins.path {
          path = ./.;
        };
        buildInputs = oldAttrs.buildInputs ++ [wlroots_0_19];
        # nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [wlroots];
      });
    })
  ];
}
