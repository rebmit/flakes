{ config, lib, ... }:
let
  cfg = config.custom.cloud.misaka;
in
with lib; {
  options.custom.cloud.misaka = {
    enable = mkEnableOption "misaka preset";
  };

  config = mkIf cfg.enable {
    custom.cloud.common.enable = true;
    custom.baseline.enable = true;

    custom.system.disko.btrfs-bios-common = {
      enable = true;
      device = "/dev/vda";
    };

    networking = {
      domain = "link.rebmit.moe";
    };

    boot = {
      initrd = {
        availableKernelModules = [
          "ahci"
          "sym53c8xx"
          "xhci_pci"
          "virtio_pci"
          "sr_mod"
          "virtio_blk"
        ];
      };
    };
  };
}
