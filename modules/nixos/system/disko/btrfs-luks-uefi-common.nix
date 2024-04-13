{ config, lib, ... }:
let
  cfg = config.custom.system.disko.btrfs-luks-uefi-common;
in
with lib; {
  options.custom.system.disko.btrfs-luks-uefi-common = {
    enable = mkEnableOption "disko preset with btrfs, luks and uefi support";
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
              cryptroot = {
                label = "CRYPTROOT";
                size = "100%";
                content = {
                  type = "luks";
                  name = "cryptroot";
                  settings = {
                    allowDiscards = true;
                    bypassWorkqueues = true;
                    crypttabExtraOpts = [
                      "same-cpu-crypt"
                      "submit-from-crypt-cpus"
                    ];
                  };
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
