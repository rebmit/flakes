{ lib, pkgs, config, ... }: {
  custom.containers."router" = {
    autoStart = true;
    privateNetwork = true;
    ephemeral = true;
    extraVeths."router-lan".hostBridge = "brlan";
    extraVeths."router-wan".hostBridge = "brwan";
    bindMounts."${config.sops.templates.router-xl2tpd.path}" = { };
    bindMounts."${config.sops.templates.router-pppoptions.path}" = { };
    bindMounts."/dev/ppp" = {
      isReadOnly = false;
      useRootIdMap = false;
    };
    privileged = true;
    allowedDevices = [
      {
        modifier = "rw";
        node = "/dev/ppp";
      }
    ];
    config = {
      networking = {
        useHostResolvConf = lib.mkForce false;
        firewall.enable = false;
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
          global = {
            family = "ip";
            content = ''
              chain input_ppp0 {
              }

              chain input_wan {
              }

              chain input_lan {
                icmp type echo-request limit rate 5/second accept
              }

              chain input {
                type filter hook input priority mangle; policy drop;
                ct state vmap { established : accept, related : accept, invalid : drop }
                iifname vmap { lo : accept, ppp0 : jump input_ppp0, router-wan : jump input_wan, router-lan : jump input_lan }
              }

              chain forward {
                type filter hook forward priority mangle; policy drop;
                ct state vmap { established : accept, related : accept, invalid : drop }
                iifname router-lan accept
              }

              chain postrouting {
                type nat hook postrouting priority srcnat; policy accept;

                ip saddr 10.224.0.0/20 oifname router-wan masquerade
                ip saddr 10.224.0.0/20 oifname ppp0 masquerade
              }
            '';
          };
        };
      };

      systemd.network = {
        enable = true;
        wait-online.enable = false;
        networks = {
          "20-wan" = {
            name = "router-wan";
            networkConfig = {
              DHCP = "ipv4";
              IPv6AcceptRA = "no";
            };
            dhcpV4Config = {
              SendHostname = false;
              UseDNS = false;
              UseRoutes = false;
              UseGateway = false;
              RouteTable = 200;
              RouteMetric = 2048;
            };
            routes = [
              {
                routeConfig = {
                  Table = 200;
                  Gateway = "_dhcp4";
                  Destination = "172.16.0.0/12";
                };
              }
              {
                routeConfig = {
                  Table = 200;
                  Gateway = "_dhcp4";
                  Destination = "192.168.0.0/16";
                };
              }
            ];
            routingPolicyRules = [
              {
                routingPolicyRuleConfig = {
                  Table = 200;
                  Priority = 20000;
                };
              }
            ];
          };
          "20-lan" = {
            name = "router-lan";
            addresses = [
              {
                addressConfig = {
                  Address = "10.224.0.2/20";
                  AddPrefixRoute = false;
                };
              }
            ];
            networkConfig = {
              DHCP = "no";
              IPv6AcceptRA = "no";
            };
            routes = [
              {
                routeConfig = {
                  Table = 150;
                  Destination = "10.224.0.2/20";
                };
              }
            ];
            routingPolicyRules = [
              {
                routingPolicyRuleConfig = {
                  Table = 150;
                  Priority = 15000;
                };
              }
            ];
          };
        };
      };

      systemd.services.xl2tpd-client =
        let
          xl2tpd-ppp-wrapped = pkgs.stdenv.mkDerivation {
            name = "xl2tpd-ppp-wrapped";
            phases = [ "installPhase" ];
            nativeBuildInputs = with pkgs; [ makeWrapper ];
            installPhase = ''
              mkdir -p $out/bin

              makeWrapper ${pkgs.ppp}/sbin/pppd $out/bin/pppd \
                --set LD_PRELOAD    "${pkgs.libredirect}/lib/libredirect.so" \
                --set NIX_REDIRECTS "/etc/ppp=/etc/xl2tpd/ppp"

              makeWrapper ${pkgs.xl2tpd}/bin/xl2tpd $out/bin/xl2tpd \
                --set LD_PRELOAD    "${pkgs.libredirect}/lib/libredirect.so" \
                --set NIX_REDIRECTS "${pkgs.ppp}/sbin/pppd=$out/bin/pppd"
            '';
          };
        in
        {
          description = "xl2tpd client";

          requires = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];

          preStart = ''
            mkdir -p /run/xl2tpd
            chown root:root /run/xl2tpd
            chmod 700       /run/xl2tpd
          '';

          serviceConfig = {
            ExecStart = "${xl2tpd-ppp-wrapped}/bin/xl2tpd -D -c ${config.sops.templates.router-xl2tpd.path} -p /run/xl2tpd/pid -C /run/xl2tpd/control";
            KillMode = "process";
            Restart = "on-success";
            Type = "simple";
            PIDFile = "/run/xl2tpd/pid";
          };
        };

      services.resolved.enable = true;

      system.stateVersion = "23.11";
    };
  };
}
