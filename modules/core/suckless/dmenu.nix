{
  config,
  pkgs,
  lib,
  ...
}: let
  run_history = pkgs.writeShellScriptBin "dmenu_run" ''
    #!/bin/sh

    cachedir=''${XDG_CACHE_HOME:-"$HOME/.cache"}
    if [ -d "$cachedir" ]; then
    	cache=$cachedir/dmenu_run
    	historyfile=$cachedir/dmenu_history
    else			# if no xdg dir, fall back to dotfiles in ~
    	cache=$HOME/.dmenu_cache
    	historyfile=$HOME/.dmenu_history
    fi

    IFS=:
    if stest -dqr -n "$cache" $PATH; then
    	stest -flx $PATH | sort -u > "$cache"
    fi
    unset IFS

    prompt=$(
    	awk '
    		$1 > 20 {
    			sub("^[0-9]+\t","")
    			cmds[++n]=$0
    		}
    		END {
    			for (i=1; i<=n; i++) {
    				printf "%s%s", cmds[i], (i<n ? "," : "")
    			}
    		}
    	' "$historyfile"
    )

    cat "$cache" \
    | dmenu -n -hp "$prompt" "$@" \
    | awk -v histfile=$historyfile '
    	BEGIN {
    		FS=OFS="\t"
    		while ( (getline < histfile) > 0 ) {
    			count=$1
    			sub("^[0-9]+\t","")
    			fname=$0
    			history[fname]=count
    		}
    		close(histfile)
    	}

    	{
    		history[$0]++
    		print
    	}

    	END {
    		if(!NR) exit
    		for (f in history)
    			print history[f],f | "sort -t '\t' -k1rn >" histfile
    	}
    ' \
    | while read cmd; do ''${SHELL:-"/bin/sh"} -c "$cmd" & done
  '';
in {
  environment.persistence."/persist".users.dex.files = [
    ".cache/dmenu_run"
    ".cache/dmenu_history"
  ];

  environment.systemPackages = with pkgs; [
    run_history
    (dmenu.overrideAttrs (
      oldAttrs: rec {
        src = builtins.path {
          path = ./dmenu;
        };
        buildInputs = oldAttrs.buildInputs ++ [libspng];
      }
    ))
  ];
  #patches applied
  #  mouse support
  #  fuzzy finding
  #  dmenu center
  #  instant
}
