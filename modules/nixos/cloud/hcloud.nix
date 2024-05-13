{ config, lib, ... }:
let
  cfg = config.custom.cloud.hcloud;
in
with lib; {
  options.custom.cloud.hcloud = {
    enable = mkEnableOption "hcloud preset";
  };

  config = mkIf cfg.enable {
    custom.cloud.common = {
      enable = true;
      dhcp = false;
    };
    custom.baseline.enable = true;

    custom.system.disko.btrfs-bios-common = {
      enable = true;
      device = "/dev/vda";
    };

    boot = {
      initrd = {
        availableKernelModules = [
          "ata_piix"
          "uhci_hcd"
          "virtio_pci"
          "virtio_scsi"
          "ahci"
          "sd_mod"
          "sr_mod"
          "virtio_blk"
        ];
      };
    };
  };
}
