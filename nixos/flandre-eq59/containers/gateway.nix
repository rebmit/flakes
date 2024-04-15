{ lib, config, pkgs, myvars, mylib, ... }:
let
  homeNetwork = myvars.networks.homeNetwork;
  localNode = homeNetwork.nodes."flandre-eq59-gateway";
  routerNode = homeNetwork.nodes."flandre-eq59-router";
  mihomoNode = homeNetwork.nodes."flandre-eq59-mihomo";
in
{
  custom.containers."gateway" = {
    autoStart = true;
    privateNetwork = true;
    ephemeral = false;
    extraVeths."gateway-lan".hostBridge = "brlan";
    config = {
      networking = {
        useHostResolvConf = lib.mkForce false;
        firewall.enable = false;
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
              define internal_addr = {
                ${lib.concatStringsSep ",\n" homeNetwork.advertiseRoutes.ipv4}
              }

              define private_addr = {
                10.0.0.0/8,
                100.64.0.0/10,
                127.0.0.0/8,
                169.254.0.0/16,
                172.16.0.0/12,
                192.168.0.0/16,
                224.0.0.0/4,
                240.0.0.0/4,
                255.255.255.255/32
              }

              include "${pkgs.chnroutes2}/chnroutes.nft"

              chain mangle_filter {
                ip daddr { $private_addr, $chnroutes2 } meta mark set 114 counter accept
                ip protocol { tcp, udp } meta mark set 514 counter accept
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
            addresses = [
              {
                addressConfig = {
                  Address = localNode.ipv4;
                  AddPrefixRoute = false;
                };
              }
            ];
            routes = (map
              (cidr: {
                routeConfig = {
                  Table = 100;
                  Destination = cidr;
                };
              })
              homeNetwork.advertiseRoutes.ipv4) ++ [
              {
                routeConfig = {
                  Table = 101;
                  Destination = "0.0.0.0/0";
                  Gateway = (mylib.networking.ipv4.cidrToIpAddress routerNode.ipv4);
                };
              }
              {
                routeConfig = {
                  Table = 102;
                  Destination = "0.0.0.0/0";
                  Gateway = (mylib.networking.ipv4.cidrToIpAddress mihomoNode.ipv4);
                };
              }
            ];
            routingPolicyRules = [
              {
                routingPolicyRuleConfig = {
                  Table = 100;
                  Priority = 10000;
                };
              }
              {
                routingPolicyRuleConfig = {
                  Table = 101;
                  FirewallMark = 114;
                  Priority = 10100;
                };
              }
              {
                routingPolicyRuleConfig = {
                  Table = 102;
                  FirewallMark = 514;
                  Priority = 10200;
                };
              }
            ];
          };
        };
      };

      services.resolved.enable = lib.mkForce false;

      system.stateVersion = "23.11";
    };
  };
}

