{
  self,
  inputs,
  ...
}: {

  perSystem = {pkgs,self', ...}: {
    packages.zsh =
      (inputs.wrappers.wrapperModules.zsh.apply {
        inherit pkgs;
        settings = {
          keyMap = "viins";
          autocd = true;
          integrations.zoxide.enable = true;

          integrations.oh-my-posh = {
            enable = true;
            package = self'.packages.oh-my-posh;
          };

          completion = {
            enable = true;
            extraCompletions = true;
            colors = true;
            caseInsensitive = true;
            fuzzySearch = true;
          };
          autoSuggestions.enable = true;

          history = {
            share = true;
            expireDupsFirst = true;
            findNoDups = true;
            ignoreDups = true;
            ignoreSpace = true;
            expanded = true;
          };
        };
      }).wrapper;
  };
}
