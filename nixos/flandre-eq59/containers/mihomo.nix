{ lib, config, pkgs, ... }: {
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
            name_servers='10.224.0.3'
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
              define internal_addr = { 10.224.0.0/20 }

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

              chain mangle_proxy {
                ip daddr $private_addr counter accept
                ip daddr $chnroutes2 counter accept
                ip protocol { tcp, udp } tproxy to 127.0.0.1:7893 meta mark set 114514 counter accept
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
            address = [ "10.224.0.4/20" ];
            gateway = [ "10.224.0.2" ];
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

