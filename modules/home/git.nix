{ pkgs, ... }:{

	programs.gh = {
		enable = true;
	};
	programs.git = {
		enable = true;
		settings = {
			user = {
				name = "dexter-latcham";
				email = "flatcapdex@pm.me";
			};
			init.defaultBranch = "main";
		};
	};
  home.persistence."/persist".files = [
		".config/gh/hosts.yml"
	];
}
