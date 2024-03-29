{ lib, pkgs, ... }: {
  containers."smartdns" = {
    autoStart = true;
    privateNetwork = true;
    ephemeral = true;
    extraVeths."lan".hostBridge = "brlan";
    extraFlags = [ "-U" ];
    config = {
      networking = {
        firewall.enable = false;
        resolvconf = {
          enable = true;
          useLocalResolver = true;
        };
      };

      services.resolved.enable = lib.mkForce false;

      systemd.network = {
        enable = true;
        wait-online.enable = false;
        networks = {
          "20-lan" = {
            name = "lan";
            address = [ "10.224.0.2/20" ];
            gateway = [ "10.224.0.254" ];
          };
        };
      };

      services.smartdns = {
        enable = true;
        bindPort = 53;
        settings = {
          server-name = "smartdns";
          conf-file = "${pkgs.smartdns-china-list}/accelerated-domains.china.domain.smartdns.conf";

          prefetch-domain = "yes";
          speed-check-mode = "none";
          force-AAAA-SOA = "yes";
          force-qtype-SOA = "65";

          server-https = [
            "https://146.112.41.2/dns-query"
          ];

          server-tls = [
            "223.5.5.5:853 -group domestic -exclude-default-group"
            "223.6.6.6:853 -group domestic -exclude-default-group"
            "1.12.12.12:853 -group domestic -exclude-default-group"
            "120.53.53.53:853 -group domestic -exclude-default-group"
          ];

          audit-enable = "yes";
        };
      };

      system.stateVersion = "23.11";
    };
  };
}
