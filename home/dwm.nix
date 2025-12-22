{pkgs,...}:
{
home.packages= [
(pkgs.writeScriptBin "screenshot" ''
      #!/usr/bin/env sh
      set -e

      output="$(date '+%y%m%d-%H%M-%S').png"

      xclip_img="${pkgs.xclip}/bin/xclip -sel clip -t image/png"
      xclip_txt="${pkgs.xclip}/bin/xclip -sel clip"

      choice="$(
        printf "%s\n" \
          "a selected area" \
          "current window" \
          "full screen" \
          "a selected area (copy)" \
          "current window (copy)" \
          "full screen (copy)" \
          "copy selected image to text" |
        ${pkgs.dmenu}/bin/dmenu -l 7 -i -p "Screenshot which area?"
      )"

      case "$choice" in
        "a selected area")
          ${pkgs.maim}/bin/maim -u -s "pic-selected-$output"
          ;;
        "current window")
          ${pkgs.maim}/bin/maim -B -q -d 0.2 \
            -i "$(${pkgs.xdotool}/bin/xdotool getactivewindow)" \
            "pic-window-$output"
          ;;
        "full screen")
          ${pkgs.maim}/bin/maim -q -d 0.2 "pic-full-$output"
          ;;
        "a selected area (copy)")
          ${pkgs.maim}/bin/maim -u -s | $xclip_img
          ;;
        "current window (copy)")
          ${pkgs.maim}/bin/maim -q -d 0.2 \
            -i "$(${pkgs.xdotool}/bin/xdotool getactivewindow)" |
            $xclip_img
          ;;
        "full screen (copy)")
          ${pkgs.maim}/bin/maim -q -d 0.2 | $xclip_img
          ;;
        "copy selected image to text")
          tmpfile="$(mktemp /tmp/ocr-XXXXXX.png)"
          ${pkgs.maim}/bin/maim -u -s > "$tmpfile"
          ${pkgs.tesseract}/bin/tesseract "$tmpfile" - -l eng | $xclip_txt
          rm -f "$tmpfile"
          ;;
      esac

'')
];
}
