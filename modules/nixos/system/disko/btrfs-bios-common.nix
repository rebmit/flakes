{ config, lib, ... }:
let
  cfg = config.custom.system.disko.btrfs-bios-common;
in
with lib; {
  options.custom.system.disko.btrfs-bios-common = {
    enable = mkEnableOption "disko preset with btrfs and bios support";
    device = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = cfg.device;
          content = {
            type = "gpt";
            partitions = {
              boot = {
                type = "EF02";
                label = "BOOT";
                start = "0";
                end = "+1M";
              };
              root = {
                label = "ROOT";
                end = "-0";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "boot" = {
                      mountpoint = "/boot";
                      mountOptions = [ "compress=zstd" ];
                    };
                    "nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" ];
                    };
                    "persist" = {
                      mountpoint = "/persist";
                      mountOptions = [ "compress=zstd" ];
                    };
                  };
                };
              };
            };
          };
        };
      };
      nodev = {
        "/" = {
          fsType = "tmpfs";
          mountOptions = [
            "defaults"
            "size=2G"
            "mode=755"
            "nosuid"
            "nodev"
          ];
        };
      };
    };

    fileSystems."/persist".neededForBoot = true;
  };
}
