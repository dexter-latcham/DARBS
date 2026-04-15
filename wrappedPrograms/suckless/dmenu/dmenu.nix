{
  self,
  inputs,
  lib,
  ...
}: {
  perSystem = {pkgs, ...}: {
    packages.dmenu = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.dmenu.overrideAttrs (oldAttrs:
        {
          src = builtins.path {
            path = ./.;
          };
          buildInputs = oldAttrs.buildInputs ++ [pkgs.harfbuzz];
        }
      );
      runtimeInputs = [
        (pkgs.writeShellScriptBin "dmenu_run" ''
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
              $1 > 5 {
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

          prompt2=$(
            awk '
              $1 > 5 {
    	          sub("^[0-9]+\t","")
                print $0
              }
            ' "$historyfile"
          )
          {
            printf "%s\n" "$prompt2"
            cat "$cache"
          } | uniq \
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
        '')
      ];
    };
  };
}
