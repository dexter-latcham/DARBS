{pkgs, inputs, ...}: {
  environment.systemPackages = with pkgs; [
    alejandra
    inputs.nix-auto-follow.packages.${stdenv.hostPlatform.system}.default
    inputs.nox.packages.${stdenv.hostPlatform.system}.default
  ];
}
