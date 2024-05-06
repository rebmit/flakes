{ lib, config, pkgs, myvars, mylib, ... }:
let
  serviceDomain = "mihomo.rebmit.internal";
  homeNetwork = myvars.networks.homeNetwork;
  localNode = homeNetwork.nodes."flandre-eq59-mihomo";
  routerNode = homeNetwork.nodes."flandre-eq59-router";
  localRoute = {
    Table = 100;
    FirewallMark = 114514;
    Priority = 10000;
    Destination = "0.0.0.0/0";
    Type = "local";
    Scope = "host";
  };
in
{
  custom.virtualisation.containers."mihomo" = {
    autoStart = true;
    privateNetwork = true;
    ephemeral = false;
    extraVeths."mihomo-lan".hostBridge = "brlan";
    bindMounts."${config.sops.templates.mihomo-configuration.path}" = { };
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
                routeConfig = { inherit (localRoute) Table Destination Type Scope; };
              }
            ];
            routingPolicyRules = [
              {
                routingPolicyRuleConfig = { inherit (localRoute) Table FirewallMark Priority; };
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

      system.stateVersion = "23.11";
    };
  };

  services.caddy = {
    virtualHosts."${serviceDomain}".extraConfig = ''
      tls /run/credentials/caddy.service/cert /run/credentials/caddy.service/key
      reverse_proxy ${mylib.networking.ipv4.cidrToIpAddress localNode.ipv4}:9090
    '';
  };

  custom.virtualisation.containers."smartdns".config = {
    services.smartdns.settings = {
      cname = "/${serviceDomain}/${homeNetwork.nodes.flandre-eq59.fqdn}";
    };
  };
}
