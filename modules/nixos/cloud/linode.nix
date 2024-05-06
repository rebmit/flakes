{ config, lib, ... }:
let
  cfg = config.custom.cloud.linode;
in
with lib; {
  options.custom.cloud.linode = {
    enable = mkEnableOption "linode preset";
  };

  config = mkIf cfg.enable {
    custom.cloud.common.enable = true;
    custom.baseline.enable = true;

    custom.system.disko.btrfs-bios-common = {
      enable = true;
      device = "/dev/sda";
    };

    networking = {
      domain = "link.rebmit.moe";
      usePredictableInterfaceNames = false;
    };

    boot = {
      initrd = {
        availableKernelModules = [
          "sd_mod"
          "ahci"
        ];
      };
      kernelParams = [ "console=ttyS0,19200n8" ];
      loader.grub.extraConfig = ''
        serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
        terminal_input serial;
        terminal_output serial
      '';
    };
  };
}
