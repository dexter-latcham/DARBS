{
  ns = "sudo nixos-rebuild switch --flake /etc/nixos";
  nw = "sudo nixos-rebuild switch --flake /etc/nixos/wayland";
  cd = "z";
  clip = "wl-copy";
  # clip = "xclip -selection clipboard";
  nivm = "nvim";
  v = "nvim";
  n = "nvim";
  update = "nix flake update --flake /etc/nixos; auto-follow /etc/nixos/flake.lock -i";
  # whichn = "${pkgs.nix-index}/bin/nix-locate bin/";
}
