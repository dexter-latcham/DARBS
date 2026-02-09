{ config, pkgs, ... }:
{
	 home.persistence."/persist" = {
	   directories = [
	    ".config/mozilla"
	    ".config/librewolf"
	  ];
	};



  home.file.".mozilla/native-messaging-hosts".enable = false;
  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;
    configPath = "${config.xdg.configHome}/librewolf/librewolf";
    policies = {
      # https://mozilla.github.io/policy-templates/

      DefaultDownloadDirectory = "\${HOME}/Downloads/web";
      SanitizeOnShutdown = {
        History = false;
        Cookies = false;
        Cache = true;
        FormData = true;
      };

      UserMessaging = {
        Locked = true; # Lock user messaging settings
        ExtentionRecommendations = false; # Disable extension recommendations
        FeatureRecommendations = false; # Disable feature recommendations
        SkipOnboarding = true; # Skip onboarding
        MoreFromMozilla = false; # Disable "More from Mozilla" messages
      };


      DisplayBookmarksToolbar = "always"; # Hide the bookmarks toolbar


      ExtensionSettings =
        with builtins;
        let
          extension = shortId: uuid: mode: pb: {
            name = uuid;
            value = {
              install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
              installation_mode = mode;
            }
            // (if pb then { private_browsing = true; } else { });
          };
        in
        listToAttrs [
          (extension "multi-account-containers" "@testpilot-containers" "force_installed" true)
          (extension "ublock-origin" "uBlock0@raymondhill.net" "force_installed" true)

          (extension "darkreader" "addon@darkreader.org" "force_installed" true)


          (extension "buster-captcha-solver" "{e58d3966-3d76-4cd9-8552-1582fbc800c1}" "normal_installed" false)

          #blocks canvas fingerprinting
          (extension "canvasblocker" "CanvasBlocker@kkapsner.de" "normal_installed" true)

          (extension "sponsorblock" "sponsorBlocker@ajay.app" "normal_installed" false)
          (extension "dearrow" "deArrow@ajay.app" "normal_installed" false)
          (extension "return-youtube-dislikes" "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" "normal_installed" false)
        ];
    };
    profiles = {
      default = {
        name = "default";
        isDefault = true;
        search = {
          force = true;
          default = "ddg";
          engines = { 
            myNixos = {
              urls = [{ template = "https://mynixos.com/search?q={searchTerms}"; }];
              iconUpdateUrl = "https://mynixos.com/favicon-dark.svg";
              updateInterval = 24 * 60 * 60 * 1000;
              definedAliases = [ "!mn" ];
            };
            nixos = {
              urls = [{ template = "https://search.nixos.org/options?channel=unstable&query={searchTerms}"; }];
              iconUpdateUrl = "https://search.nixos.org/favicon-96x96.png";
              updateInterval = 24 * 60 * 60 * 1000;
              definedAliases = [ "!n" ];
            };
            hmOpts = {
              urls = [{ template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master"; }];
              iconUpdateUrl = "https://home-manager-options.extranix.com/images/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000;
              definedAliases = [ "!hm" ];
            };
            "wikipedia".metaData.hidden = true;
            "perplexity".metaData.hidden = true;
            "ebay-uk".metaData.hidden = true;
            "bing".metaData.hidden = true;
          };
        };
        bookmarks = {
          force = true;
          settings = [
            {
              toolbar = true;
              bookmarks = [
                {
                  name = "mail";
                  url = "https://mail.proton.me";
                  keyword = "mail";
                }
              ];
            }
          ];
        };
      };
    };
  };
}
