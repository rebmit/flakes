{ inputs, ... }: {
  imports = [
    inputs.disko.nixosModules.disko
  ];

  disko.devices = {
    disk.vda = {
      type = "disk";
      device = "/dev/vda";
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
