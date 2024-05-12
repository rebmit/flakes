{ lib, pkgs, myvars, mylib, ... }:
let
  homeNetwork = myvars.networks.homeNetwork;
  localNode = homeNetwork.nodes."flandre-eq59-smartdns";
  routerNode = homeNetwork.nodes."flandre-eq59-router";
in
{
  custom.virtualisation.containers."smartdns" = {
    autoStart = true;
    privateNetwork = true;
    ephemeral = true;
    extraVeths."smartdns-lan".hostBridge = "brlan";
    config = {
      networking = {
        useHostResolvConf = lib.mkForce false;
        resolvconf = {
          enable = true;
          useLocalResolver = true;
        };
      };

      systemd.network = {
        enable = true;
        wait-online.enable = false;
        networks = {
          "20-lan" = {
            name = "smartdns-lan";
            address = [ localNode.ipv4 ];
            gateway = [ (mylib.networking.ipv4.cidrToIpAddress routerNode.ipv4) ];
          };
        };
      };

      services.smartdns = {
        enable = true;
        settings = {
          bind = "[::]:53";

          server-name = "smartdns";
          conf-file = "${pkgs.smartdns-china-list}/accelerated-domains.china.domain.smartdns.conf";

          prefetch-domain = "yes";
          speed-check-mode = "none";
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

          address = (lib.mapAttrsToList
            (name: node: "/${node.fqdn}/${mylib.networking.ipv4.cidrToIpAddress node.ipv4}")
            homeNetwork.nodes
          );

          audit-enable = "yes";
        };
      };

      system.stateVersion = "23.11";
    };
  };
}
