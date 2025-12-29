{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.dunst = {
    enable = true;

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
    };

    settings = {
      global = {
        follow = "keyboard";
        width = 500;
        separator_height = 1;
        padding = 24;
        horizontal_padding = 24;
        frame_width = 1;
        sort = "update";
        idle_threshold = 120;
        alignment = "center";
        word_wrap = "yes";
        transparency = 5;
        format = "<b>%s</b>: %b";
        markup = "full";
        min_icon_size = 32;
        max_icon_size = 100;
        font = "JetBrains Mono 15";
      };
    };
  };
}
