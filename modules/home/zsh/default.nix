{pkgs,config,...}:
{
  home.persistence."/persist".directories = [
    ".local/share/zoxide"
    ".local/share/zsh"
  ];

  home.packages = with pkgs; [
    oh-my-posh
      zoxide # fuzzy cd
      fzf
  ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    autocd = true; # cd by typing only directory

      defaultKeymap = "viins"; # vim mode

      history = {
        size = 10000;
        save = 10000;

        path = "${config.xdg.dataHome}/zsh/history";
        share = true;
        ignoreDups = true;
        ignoreSpace = true;
        extended = true; # save timestamps
      };
    shellAliases = import ./alias.nix;

    sessionVariables = {
      KEYTIMEOUT = "1"; # timeout when switching vim modes
        ZSH_AUTOSUGGEST_STRATEGY = "history completion";
    };
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    plugins = with pkgs; [{
      name = "fzf-tab";
      src = zsh-fzf-tab;
    }];

    completionInit = ''
      # case insensitive
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      # show menu
      zstyle ':completion:*' menu select

      # prefer history
      zstyle ':completion:*' completer _complete _history
      '';

    initContent = ''
      # startup profiling
      zmodload zsh/zprof

      # disable ctrl+s terminal pause
      stty stop undef
      # Change cursor shape for different vi modes.
      function zle-keymap-select () {
        case $KEYMAP in
          vicmd) echo -ne '\e[1 q';;      # block
          viins|main) echo -ne '\e[5 q';; # beam
          esac
      }
      zle -N zle-keymap-select
      echo -ne '\e[5 q'

      # edit current command in vim with ctrl_e
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey '^e' edit-command-line
      bindkey -M vicmd '^e' edit-command-line

      # # last command output in vim buffer
      # functin last-output() {
      #   local f
      #   f=$(mktemp)
      #   fc -ln -1 | sed '1d' > "$f"
      #   nvim "$f"
      # }
      # zle -N last-output
      #
      # bindkey '^o' last-output
      # bindkey -M vicmd '^o' last-output

      # help for command
      function man-or-help() {
        local cmd=''${BUFFER%% *}
        man "$cmd" 2>/dev/null || "$cmd" --help | less
      }
      zle -N man-or-help
      bindkey '^h' man-or-help
      bindkey -M vicmd '^h' man-or-help

      bindkey '^j' history-search-forward
      bindkey '^k' history-search-backward

      # zoxide for faster cd
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

      # oh-my-posh prompt
      eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${./prompt.toml})"
      '';
  };
}
