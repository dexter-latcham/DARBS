{inputs, ...}: {
  flake.nixosModules.extra_impermanence = {
    lib,
    config,
    ...
  }: let
    cfg = config.persistance;
  in {
    imports = [
      inputs.impermanence.nixosModules.impermanence
    ];

    config = lib.mkIf cfg.enable {
      security.sudo.extraConfig = "Defaults lecture = never";
      fileSystems."/persist".neededForBoot = true;

      programs.fuse.userAllowOther = true;


      users.users.${cfg.user}.extraGroups = ["fuse"];

      boot.tmp.cleanOnBoot = lib.mkDefault true;

      environment.persistence."/persist" = {
        hideMounts = true;
        directories = [
          "/var/lib/systemd"
          "/var/lib/bluetooth"
          "/var/lib/nixos"

          "/var/log"
          "/etc/nixos"
          "/etc/NetworkManager/system-connections"
          "/tmp"
          ] ++ cfg.directories;
        files = [
            "/etc/machine-id"
            {
              file = "/var/keys/secret_file";
              parentDirectory = {mode = "u=rwx,g=,o=";};
            }
          ] ++ cfg.files;
        users."${cfg.user}" = {
          directories = cfg.data.directories;
          files = cfg.data.files;
        };
      };
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
    };
  };
}
