{ pkgs, ... }:{
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
	home.packages = with pkgs; [
		github-cli
	];
  home.persistence."/persist".files = [
		".config/gh/hosts.yml"
	];
}
