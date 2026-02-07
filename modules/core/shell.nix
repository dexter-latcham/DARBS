{ pkgs, ... }:
{
  users.defaultUserShell = pkgs.zsh;

  environment = {
    variables = {
      TERMINAL="st";
      EDITOR="nvim";
      BROWSER="librewolf";
    };
    shells = with pkgs; [
      zsh
    ];

    programs.git = {
	enable = true;
	settings = {
		user = {
			name = "dexter-latcham";
			email = "flatcapdex@pm.me";
		};
	};
	init.defaultBranch = "main";
    };

    environment.persistence."/persist".users.dex.files = [
      ".config/gh/hosts.yml"
    ];
    systemPackages = with pkgs; [
      github-cli
      direnv
      pstree
      htop
      fastfetch
      jq
      fd
      xh
      file
      timg
      choose
      sd
      rustscan
      yt-dlp
      sox
      asak
      timer
      dig
      mtr
      mediainfo
      fdupes
      whois
      killall
      trashy
      hwinfo
      duf
      stress
      hdparm
      recode
      jpegoptim
      pass
      tango
      npm-check-updates
      microfetch
      onefetch
      scc
      genact
      sanctity
      asciiquarium-transparent
      cmatrix
      gdu
      hexyl
      pgcli
      litecli
      p7zip
      unar
      rsync
      rclone
      megacmd
      ffmpeg
      imagemagick
      smartmontools
      restic
      borgbackup
      zbar
      phraze
      lychee
      bluetui
      nixpkgs-review
      nix-init
      nix-update
      statix
      nvd
      nix-search-cli
      nix-tree
      gcc
      rustc
      rustfmt
      cargo
      cargo-tarpaulin
      bacon
      clippy
      nodejs
      monolith
      haylxon
      nix-inspect
      sherlock
      remind
      oxipng
      arion
      tabiew
      viddy
      jless
      rclip
      exiftool
      xsubfind3r
      all-the-package-names
      pik
      bottom
      pdfminer
      dos2unix
      clock-rs
      taskwarrior3
      unflac
      openai-whisper
      zizmor
      go-grip
      eclint
      editorconfig-checker
      mountpoint-s3
      signal-cli
      typos
      gallery-dl
      awscli2
      ripgrep
    ];
  };

  programs = {
    zsh.enable = true;
    neovim.enable = true;

    direnv = {
      enable = true;
      silent = true;
    };
  };
}
