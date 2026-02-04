{pkgs,...}:{

home.packages = with pkgs; [
  nil
  neovim
  git
  ripgrep
  fd
  nodejs
  clang-tools
];
}

