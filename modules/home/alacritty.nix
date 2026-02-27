{...}:{
  programs.alacritty = {
    enable = true;
    settings = {
      keyboard.bindings = [
        {
          key = "c";
          mods = "Alt";
          action = "Copy";
        }
        {
          key = "v";
          mods = "Alt";
          action = "paste";
        }
      ];
    };
  };
}
