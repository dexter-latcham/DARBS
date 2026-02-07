#this wholg thing should be replaced by nixvim
{pkgs,...}:{
  home.persistence."/persist".directories = [
  	".config/nvim"
    ".local/share/nvim/lazy"
    ".local/share/nvim/mason"
  ];
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

