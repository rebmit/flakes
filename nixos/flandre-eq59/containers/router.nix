{ lib, pkgs, config, mylib, myvars, ... }:
let
  homeNetwork = myvars.networks.homeNetwork;
  localNode = homeNetwork.nodes."flandre-eq59-router";
  lanRoute = {
    Table = 150;
    Priority = 15000;
  };
  wanRoute = {
    Table = 200;
    Priority = 20000;
  };
  wanDestinations = [ "172.16.0.0/12" "192.168.0.0/16" ];
in
{
  custom.containers."router" = {
    autoStart = true;
    privateNetwork = true;
    ephemeral = true;
    extraVeths."router-lan".hostBridge = "brlan";
    extraVeths."router-wan".hostBridge = "brwan";
    bindMounts."${config.sops.templates.router-xl2tpd.path}" = { };
    bindMounts."${config.sops.templates.router-pppoptions.path}" = { };
    bindMounts."${config.sops.templates.router-weblogin.path}" = { };
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
          global = {
            family = "ip";
            content = ''
              chain input {
                type filter hook input priority mangle; policy drop;
                iifname ppp0 ct state related,established counter accept
                iifname router-wan ct state related,established counter accept
                iifname lo counter accept
                iifname router-lan accept
              }

              chain forward {
                type filter hook forward priority mangle; policy drop;

                # mss clamping is necessary for pppol2tp
                iifname ppp0 tcp flags syn tcp option maxseg size set rt mtu
                oifname ppp0 tcp flags syn tcp option maxseg size set rt mtu

                iifname ppp0 ct state related,established counter accept
                iifname router-wan ct state related,established counter accept
                iifname router-lan counter accept
              }

              chain postrouting {
                type nat hook postrouting priority srcnat; policy accept;
                iifname router-lan oifname router-wan counter masquerade
                iifname router-lan oifname ppp0 counter masquerade
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
            routes = (map
              (cidr: {
                routeConfig = {
                  inherit (wanRoute) Table;
                  Destination = cidr;
                  Gateway = "_dhcp4";
                };
              })
              wanDestinations
            );
            routingPolicyRules = [
              {
                routingPolicyRuleConfig = { inherit (wanRoute) Table Priority; };
              }
            ];
          };
          "20-lan" = {
            name = "router-lan";
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
                  inherit (lanRoute) Table;
                  Destination = cidr;
                };
              })
              homeNetwork.advertiseRoutes.ipv4
            );
            routingPolicyRules = [
              {
                routingPolicyRuleConfig = { inherit (lanRoute) Table Priority; };
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

      systemd.timers."router-restart" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          Unit = "router-restart.service";
          OnCalendar = "*-*-* 6:05:00 Asia/Shanghai";
        };
      };

      systemd.services."router-restart" = {
        serviceConfig = {
          ExecStart = "systemctl reboot";
          Type = "oneshot";
          User = "root";
        };
      };

      systemd.timers."router-weblogin" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          Unit = "router-weblogin.service";
          OnCalendar = "*-*-* 6:10:00 Asia/Shanghai";
        };
      };

      systemd.services."router-weblogin" = {
        serviceConfig = {
          ExecStart = "${pkgs.bash}/bin/bash /run/credentials/router-weblogin.service/script";
          Type = "oneshot";
          User = "router-weblogin";
          Group = "router-weblogin";
          LoadCredential = "script:${config.sops.templates.router-weblogin.path}";
        };
      };

      users.groups.router-weblogin = { };
      users.users.router-weblogin = { isSystemUser = true; group = "router-weblogin"; };

      system.stateVersion = "23.11";
    };
  };
}
