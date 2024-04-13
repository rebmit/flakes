{ config, lib, ... }:
let
  cfg = config.custom.system.disko.btrfs-uefi-common;
in
with lib; {
  options.custom.system.disko.btrfs-uefi-common = {
    enable = mkEnableOption "disko preset with btrfs and uefi support";
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
              esp = {
                label = "ESP";
                size = "2G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              root = {
                label = "ROOT";
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = [ "compress=zstd" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
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
