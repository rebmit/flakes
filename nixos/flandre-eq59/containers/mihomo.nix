{ lib, config, pkgs, myvars, mylib, ... }:
let
  homeNetwork = myvars.networks.homeNetwork;
  localNode = homeNetwork.nodes."flandre-eq59-mihomo";
  routerNode = homeNetwork.nodes."flandre-eq59-router";
in
{
  custom.containers."mihomo" = {
    autoStart = true;
    privateNetwork = true;
    ephemeral = false;
    extraVeths."mihomo-lan".hostBridge = "brlan";
    bindMounts."${config.sops.templates.mihomo-configuration.path}" = { };
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

              chain mangle_proxy {
                ip daddr $private_addr counter accept
                ip protocol { tcp, udp } tproxy to 127.0.0.1:7893 meta mark set 114514 counter accept
                ip protocol icmp counter reject with icmp type admin-prohibited
              }

              chain mangle_prerouting {
                type filter hook prerouting priority mangle; policy drop;
                ip saddr $internal_addr ip daddr $internal_addr counter accept
                ip saddr $internal_addr ip daddr != $internal_addr counter jump mangle_proxy
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
            name = "mihomo-lan";
            address = [ localNode.ipv4 ];
            gateway = [ (mylib.networking.ipv4.cidrToIpAddress routerNode.ipv4) ];
          };
          "20-lo" = {
            name = "lo";
            routes = [
              {
                routeConfig = {
                  Table = 100;
                  Destination = "0.0.0.0/0";
                  Type = "local";
                  Scope = "host";
                };
              }
            ];
            routingPolicyRules = [
              {
                routingPolicyRuleConfig = {
                  Table = 100;
                  FirewallMark = 114514;
                };
              }
            ];
          };
        };
      };

      services.mihomo = {
        enable = true;
        configFile = config.sops.templates.mihomo-configuration.path;
        webui = "${pkgs.metacubexd}";
        tunMode = true;
      };

      services.resolved.enable = lib.mkForce false;

      system.stateVersion = "23.11";
    };
  };
}
