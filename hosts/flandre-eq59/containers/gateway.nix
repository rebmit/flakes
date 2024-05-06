{ lib, pkgs, myvars, mylib, ... }:
let
  homeNetwork = myvars.networks.homeNetwork;
  localNode = homeNetwork.nodes."flandre-eq59-gateway";
  routerNode = homeNetwork.nodes."flandre-eq59-router";
  mihomoNode = homeNetwork.nodes."flandre-eq59-mihomo";
  routerRoute = {
    Table = 101;
    FirewallMark = 114;
    Priority = 10100;
    Destination = "0.0.0.0/0";
    Gateway = (mylib.networking.ipv4.cidrToIpAddress routerNode.ipv4);
  };
  mihomoRoute = {
    Table = 102;
    FirewallMark = 514;
    Priority = 10200;
    Destination = "0.0.0.0/0";
    Gateway = (mylib.networking.ipv4.cidrToIpAddress mihomoNode.ipv4);
  };
in
{
  custom.virtualisation.containers."gateway" = {
    autoStart = true;
    privateNetwork = true;
    ephemeral = false;
    extraVeths."gateway-lan".hostBridge = "brlan";
    config = {
      networking = {
        useHostResolvConf = lib.mkForce false;
        resolvconf = {
          enable = true;
          extraConfig = ''
            name_servers='${mylib.networking.ipv4.cidrToIpAddress homeNetwork.nameserver.ipv4}'
          '';
        };
      };

      boot.kernel.sysctl = {
        "net.ipv6.conf.default.forwarding" = 1;
        "net.ipv4.conf.default.forwarding" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
        "net.ipv4.conf.all.forwarding" = 1;
      };

      networking.nftables = {
        enable = true;
        tables = {
          global4 = {
            family = "ip";
            content = ''
              define internal_addr = {${lib.concatStringsSep "," homeNetwork.advertiseRoutes.ipv4}}
              define private_addr = {${lib.concatStringsSep "," myvars.constants.bogonAddresses.ipv4}}
              include "${pkgs.chnroutes2}/chnroutes.nft"

              chain mangle_filter {
                ip daddr { $private_addr, $chnroutes2 } meta mark set ${toString routerRoute.FirewallMark} counter accept
                ip protocol { tcp, udp, icmp } meta mark set ${toString mihomoRoute.FirewallMark} counter accept
              }

              chain mangle_prerouting {
                type filter hook prerouting priority mangle; policy drop;
                ip saddr $internal_addr ip daddr $internal_addr counter accept
                ip saddr $internal_addr ip daddr != $internal_addr counter jump mangle_filter;
                ct state related,established counter accept
              }
            '';
          };
        };
      };

      systemd.network = {
        enable = true;
        wait-online.enable = false;
        networks = {
          "20-lan" = {
            name = "gateway-lan";
            address = [ localNode.ipv4 ];
            routes = (map
              (route: {
                routeConfig = { inherit (route) Table Destination Gateway; };
              })
              [ routerRoute mihomoRoute ]
            );
            routingPolicyRules = (map
              (route: {
                routingPolicyRuleConfig = { inherit (route) Table FirewallMark Priority; };
              })
              [ routerRoute mihomoRoute ]
            );
          };
        };
      };

      services.kea.dhcp4 = {
        enable = true;
        settings = {
          interfaces-config.interfaces = [ "gateway-lan" ];
          lease-database = {
            name = "/var/lib/kea/dhcp4.leases";
            persist = true;
            type = "memfile";
          };
          rebind-timer = 2000;
          renew-timer = 1000;
          subnet4 = [
            {
              inherit (homeNetwork.dhcp4) subnet pools;
              option-data = [
                {
                  name = "routers";
                  data = (mylib.networking.ipv4.cidrToIpAddress homeNetwork.gateway.ipv4);
                }
                {
                  name = "domain-name-servers";
                  data = (mylib.networking.ipv4.cidrToIpAddress homeNetwork.nameserver.ipv4);
                }
              ];
            }
          ];
          valid-lifetime = 4000;
        };
      };

      system.stateVersion = "23.11";
    };
  };
}
