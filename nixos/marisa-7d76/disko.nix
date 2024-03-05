{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
  ];

  disko.devices = {
    disk = {
      nvme = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:04:00.0-nvme-1";
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
                mountOptions = ["umask=0077"];
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
                  extraArgs = ["-f"];
                  subvolumes = {
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = ["compress=zstd"];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd"];
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
}
