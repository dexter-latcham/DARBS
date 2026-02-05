{inputs, lib,...}: {
  boot.initrd.postMountCommands = lib.mkAfter ''
		set -e # exit on any error # Temporary mount point 
		mkdir -p /btrfs_tmp # Mount the decrypted root BTRFS subvolume 
		mount -o subvol=/root /dev/mapper/cryptroot /btrfs_tmp 

		# Prepare old roots directory 
		mkdir -p /btrfs_tmp/old_roots 

		# Move existing root to timestamped old_roots if it exists 
		if [ -d /btrfs_tmp/root ]; then 
			timestamp=$(date -u +"%Y-%m-%d_%H-%M-%S") 
			mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp" || true 
		fi
		# Function to recursively delete BTRFS subvolumes 
		delete_subvolume_recursively() {
			local subvol_path="$1"
			# Delete nested subvolumes first 
			for nested in $(btrfs subvolume list -o "$subvol_path" | awk '{for(i=9;i<=NF;i++) printf $i " "; print ""}'); do 
				delete_subvolume_recursively "/btrfs_tmp/$nested" 
			done 
			btrfs subvolume delete "$subvol_path" || true 
		} 
		# Delete old snapshots older than 30 days 
		find /btrfs_tmp/old_roots/ -mindepth 1 -maxdepth 1 -type d -mtime +30 | while read old; do 
			delete_subvolume_recursively "$old" 
		done 
		# Create a fresh root subvolume 
		btrfs subvolume create /btrfs_tmp/root 
		# Unmount temporary mount 
		umount /btrfs_tmp
  '';


  programs.fuse.userAllowOther = true;
  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/lib/systemd"
      "/var/log"
      "/etc/nixos"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.dex = {
      directories = [
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
        { directory = ".gnupg"; mode = "0700"; }
        { directory = ".ssh"; mode = "0700"; }
        { directory = ".nixops"; mode = "0700"; }
        { directory = ".local/share/keyrings"; mode = "0700"; }
        ".local/share/direnv"
      ];
      files = [
        ".screenrc"
      ];
    };
  };
}
