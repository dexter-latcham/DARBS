{
  self,
  inputs,
  ...
}: {
  perSystem = {pkgs, ...}: {
    packages.oh-my-posh = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.oh-my-posh;
      flags = {
        "--config" = "${./prompt.toml}";
      };
    };
  };
}
