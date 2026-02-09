{inputs,pkgs,config,...}:{

  home.persistence."/persist".directories = [
		".config/discord"
	];
  imports = [ inputs.nixcord.homeModules.nixcord ];

  xsession = {
    initExtra = ''
      discord --start-minimized &
    '';
  };
  programs.nixcord = {
    enable = true;
    openASAR.enable = true;
    config = {
      frameless = true;
      plugins = {
        messageLogger = {
          enable = true;
          ignoreSelf = true;
        };
        volumeBooster = {
          enable = true;
          multiplier = 1.5;
        };
        fakeNitro.enable = true;
        fixImagesQuality.enable = true;
        imageZoom.enable = true;
        openInApp.enable = true;
        platformIndicators.enable = true;
        typingIndicator.enable = true;
        unlockedAvatarZoom.enable = true;
        whoReacted.enable = true;
        youtubeAdblock.enable = true;
        biggerStreamPreview.enable = true;
        moreQuickReactions.enable = true;
        anonymiseFileNames.enable = true;
        fixYoutubeEmbeds.enable = true;
        showHiddenChannels.enable = true;
        showMeYourName.enable = true;
        vcNarrator= {
          enable = true;
          voice = "serena pico";
        };
      };
    };
  };
}
