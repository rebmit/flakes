{ config, pkgs, lib, self, ... }:
let
  cfg = config.custom.baseline;
in
with lib; {
  options.custom.baseline = {
    enable = mkEnableOption "baseline configuration";
  };

  config = mkIf cfg.enable {
    boot = {
      tmp.useTmpfs = true;
      initrd.systemd.enable = true;
      kernelPackages = pkgs.linuxPackages_latest;
      kernel = {
        sysctl = {
          "kernel.panic" = 60;
          "kernel.sysrq" = 1;
          "net.core.default_qdisc" = "fq";
          "net.ipv4.tcp_congestion_control" = "bbr";
          "net.core.rmem_max" = 2500000;
          "net.core.wmem_max" = 2500000;
        };
      };
    };

    networking = {
      firewall.enable = lib.mkDefault false;
      useDHCP = false;
      useNetworkd = false;
    };

    services = {
      fstrim.enable = true;
      journald = {
        extraConfig = ''
          SystemMaxUse=1G
        '';
      };
      resolved = {
        dnssec = "false";
        llmnr = "false";
        extraConfig = ''
          MulticastDNS=off
        '';
      };
      zram-generator = {
        enable = true;
        settings.zram0 = {
          compression-algorithm = "zstd";
          zram-size = "ram";
        };
      };
    };
  };
}
