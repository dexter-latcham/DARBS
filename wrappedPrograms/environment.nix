{
lib,
inputs,
self,
...
}:{
  perSystem = {
    pkgs,
    self',
    ...
  }:{
    packages.terminal = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = self'.packages.st;
      runtimeInputs = [
        self'.packages.shell
      ];
      env = {
        TERMINAL = lib.getExe self'.packages.st;
      };
    };

    packages.shell = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = self'.packages.zsh;
      runtimeInputs = with pkgs; [
        fastfetch
        pstree
        htop
        jq
        fd
        file
        pass
        killall
        p7zip
        unzip
        zip
        wget
        htop
        btop
        bluetui
        nmtui
        rsync
        rclone
        ffmpeg
        imagemagick
        ripgrep
        neovim
        bc
      ];
      env = {
        EDITOR = lib.getExe pkgs.neovim;
      };
    }; 
  };
}
