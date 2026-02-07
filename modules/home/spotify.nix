{inputs, lib, pkgs,...}:{

  home.persistence."/persist".directories = [
		".config/spotify"
	];



  imports = [ inputs.spicetify-nix.homeManagerModules.spicetify ];
  stylix.targets.spicetify.colors.enable = false;
  programs.spicetify = 
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
  {
    enable = true;
    enabledExtensions = with spicePkgs.extensions;[
      loopyLoop
      featureShuffle
      catJamSynced
    ];
    enabledCustomApps = with spicePkgs.apps; [
      ncsVisualizer
    ];
    # theme = spicePkgs.themes.catppuccin;
    # colorScheme = lib.mkForce "mocha";
  };
}
