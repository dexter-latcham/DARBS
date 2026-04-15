{
  flake.diskoConfigurations.hostLaptop = {
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-WD_PC_SN740_SDDPNQD-512G-1002_24020W800526"; #512gb
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                label = "boot";
                name = "ESP";
                size = "1024M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["defaults"];
                };
              };
              luks = {
                size = "100%";
                label = "luks";
                content = {
                  type = "luks";
                  name = "cryptroot";
                  settings.allowDiscards = true; # Enables TRIM, reducing wear on SSDs
                  settings.bypassWorkqueues = true; # speed up for ssds
                  content = {
                    type = "btrfs";
                    extraArgs = ["-L" "nixos" "-f"];
                    subvolumes = {
                      "/root" = {
                        mountpoint = "/";
                        mountOptions = [
                          "subvol=root"
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "/nix" = {
                        mountpoint = "/nix";
                        mountOptions = [
                          "subvol=nix"
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "/persist" = {
                        mountpoint = "/persist";
                        mountOptions = [
                          "subvol=persist"
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "/swap" = {
                        mountpoint = "/.swapvol";
                        swap.swapfile.size = "8192M";
                      };
                    };
                  };
                };
              };
            };
          };
        };
        games = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-PM981_NVMe_Samsung_256GB__S443NA0K821316";
          content = {
            type = "gpt";
            partitions = {
              games = {
                size = "100%";
                label = "games";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/games";
                  mountOptions = [
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
