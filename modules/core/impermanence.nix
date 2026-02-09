{
  inputs,
  lib,
  ...
}: {
  programs.fuse.userAllowOther = true;
  users.users.dex.extraGroups = ["fuse"];
  boot.initrd.availableKernelModules = ["btrfs" "dm-mod" "dm-crypt"];
  boot.initrd.kernelModules = ["btrfs" "dm-mod" "dm-crypt"];
  boot.initrd.systemd.services.btrfs-setup = {
    description = "setup new root subvolume";
    wantedBy = ["initrd.target"];
    after = ["dev-mapper-cryptroot.device"];
    requires = ["dev-mapper-cryptroot.device"];
    before = ["sysroot.mount"];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      if [ ! -e /dev/mapper/cryptroot ]; then
          echo "❌ LUKS device not found - trying to open..."
          cryptsetup luksOpen /dev/disk/by-label/luks cryptroot || {
              echo "❌ Failed to open LUKS device"
              exit 1
          }
      fi

      mkdir -p /tmp/mnt-btrfs-root
      if ! mount -t btrfs /dev/mapper/cryptroot /tmp/mnt-btrfs-root -o subvolid=5,compress=zstd; then
          echo "❌ Failed to mount btrfs root (subvolid=5)"
          exit 1
      fi

      cd /tmp/mnt-btrfs-root
      timestamp=$(date +%Y%m%d-%H%M%S)

      if [ ! -d "nix" ] || [ ! -d "persist" ]; then
          echo "❌ CRITICAL: nix or persist missing! Aborting."
          cd /
          umount /tmp/mnt-btrfs-root
          exit 1
      fi

      delete_subvolume_recursively() {
          local subvol_path="$1"
          btrfs subvolume list -o "$subvol_path" 2>/dev/null | cut -f9 -d' ' | while read -r nested; do
              btrfs subvolume delete "$nested" 2>/dev/null || true
          done
          btrfs subvolume delete "$subvol_path" 2>/dev/null || true
      }

      if [ -e "root" ]; then
          btrfs subvolume snapshot "root" "root-old-$timestamp" 2>/dev/null || true
          delete_subvolume_recursively "root"
      fi
      btrfs subvolume create "root"

      find . -maxdepth 1 -name "root-old-*" -type d 2>/dev/null | sort -r | tail -n +4 | while IFS= read -r old; do
        btrfs subvolume delete "./$old" 2>/dev/null || true
      done

      cd /
      umount /tmp/mnt-btrfs-root
      rmdir /tmp/mnt-btrfs-root 2>/dev/null || true
    '';
  };
  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/lib/systemd"
      "/var/lib/bluetooth"
      "/var/lib/nixos"

      "/var/log"
      "/etc/nixos"
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
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".nixops";
          mode = "0700";
        }
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
        ".local/share/direnv"
      ];
      files = [
        ".screenrc"
      ];
    };
  };
  security.sudo.extraConfig = "Defaults lecture = never";
}
