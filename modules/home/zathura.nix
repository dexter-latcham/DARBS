{
  programs.zathura = {
    enable = true;

    options = {
      guioptions = "v";
      recolor = "true";
      selection-clipboard="clipboard";
      adjust-open = "width";
      statusbar-basename = true;
      render-loading = false;
      scroll-step = 120;
    };
  };
}
