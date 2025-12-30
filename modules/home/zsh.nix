{pkgs,config,...}:
{
programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    completionInit = "autoload -U compinit && compinit";
    plugins = [{ name = "zsh-autocomplete"; src = pkgs.zsh-autocomplete; }];
    shellAliases = {
      ns = "sudo nixos-rebuild switch --flake /etc/nixos";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
      save = 10000;
    };
  };
  }
