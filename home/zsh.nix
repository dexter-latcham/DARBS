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
      ls = "ls --color=auto -F";
      ll = "ls -alhF";
      la = "ls -AF";
      l = "ls -CF";
      glog = "git log --oneline --graph --decorate --all";
      # nix-update-system = "sudo nixos-rebuild switch --flake ~/Utveckling/NixOS#nixos"; # Your Flake path
      cc = "clang";
      cxx = "clang++";
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
