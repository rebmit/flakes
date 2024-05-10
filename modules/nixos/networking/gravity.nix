{ config, pkgs, lib, myvars, ranet, ... }:
with lib;
let
  cfg = config.custom.networking.gravity;
  peerOpts = { ... }: {
    options = {
      publicKey = mkOption {
        type = types.str;
        description = "public key for the remote node";
      };
      sendPort = mkOption {
        type = types.int;
        description = "listen port on the local node for the peer-to-peer tunnel";
      };
      addressFamily = mkOption {
        type = types.enum [ "ip4" "ip6" ];
        description = "address family of the given address";
      };
      endpoint = mkOption {
        type = types.nullOr types.str;
        description = "publicly accessible endpoint for the remote peer";
      };
      persistentKeepalive = mkOption {
        type = types.nullOr types.int;
        description = "the interval of keepalive packet to keep a stateful firewall valid persistently";
      };
    };
  };
  mapOpts = { ... }: {
    options = {
      source = mkOption {
        type = types.str;
        description = "source ipv6 cidr block";
      };
      target = mkOption {
        type = types.str;
        description = "target ipv6 cidr block";
      };
    };
  };
in
{
  options.custom.networking.gravity = {
    enable = mkEnableOption ''
      declarative overlay network based on wireguard, heavily inspired by
      <https://github.com/NickCao/flakes/blob/master/modules/gravity/default.nix>
    '';
    wireguard = {
      enable = mkEnableOption "wireguard";
      privateKeyPath = mkOption {
        type = types.str;
        description = "private key path for the local node";
      };
      peers = mkOption {
        type = with types; listOf (submodule peerOpts);
        default = { };
        description = "remote peers of the local node";
      };
      prefix = mkOption {
        type = types.str;
        description = "address prefix for ranet interfaces";
      };
    };
    table = mkOption {
      type = types.int;
      default = 2000;
      description = "routing table number for the vrf interfaces";
    };
    address = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "list of ipv6 addresses to be added to the vrf interfaces";
    };
    bird = {
      enable = mkEnableOption "bird integration";
      routes = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "ipv6 routes inside the vrf to be announced for local node";
      };
    };
    exit = {
      enable = mkEnableOption "exit node";
      type = mkOption {
        type = types.enum [ "transit" "peer" "customer" ];
        description = "type of the network outside the vrf";
      };
      routes = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "ipv6 routes outside the vrf to be announced for local node";
      };
      routeAll = {
        enable = mkEnableOption "whether to advertise routes ::/0";
        allow = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "list of addresses allowed to use the gateway";
        };
      };
    };
    nptv6 = {
      enable = mkEnableOption "stateless ipv6 prefix translation";
      oif = mkOption {
        type = types.str;
        default = "eth0";
        description = "name of ipv6 outbound interface";
      };
      maps = mkOption {
        type = with types; listOf (submodule mapOpts);
        default = [ ];
        description = "prefix translation mappings";
      };
    };
  };

  config = mkIf cfg.enable (
    mkMerge [
      {
        boot.kernelModules = [ "vrf" ];
        boot.kernel.sysctl = {
          "net.vrf.strict_mode" = 1;
          "net.ipv6.conf.default.forwarding" = 1;
          "net.ipv4.conf.default.forwarding" = 1;
          "net.ipv6.conf.all.forwarding" = 1;
          "net.ipv4.conf.all.forwarding" = 1;
          # https://www.kernel.org/doc/html/latest/networking/vrf.html#applications
          # established sockets will be created in the VRF based on the ingress interface
          # in case ingress traffic comes from inside the VRF targeting VRF external addresses
          # the connection would silently fail
          "net.ipv4.tcp_l3mdev_accept" = 0;
          "net.ipv4.udp_l3mdev_accept" = 0;
          "net.ipv4.raw_l3mdev_accept" = 0;
        };

        environment.etc."iproute2/rt_tables.d/gravity.conf" = {
          mode = "0644";
          text = ''
            ${toString cfg.table} gravity
          '';
        };

        systemd.services.gravity-rules = {
          path = with pkgs; [ iproute2 coreutils ];
          script = ''
            ip -4 ru del pref 0 || true
            ip -6 ru del pref 0 || true
            if [ -z "$(ip -4 ru list pref 2000)" ]; then
              ip -4 ru add pref 2000 l3mdev unreachable proto kernel
            fi
            if [ -z "$(ip -6 ru list pref 2000)" ]; then
              ip -6 ru add pref 2000 l3mdev unreachable proto kernel
            fi
            if [ -z "$(ip -4 ru list pref 3000)" ]; then
              ip -4 ru add pref 3000 lookup local proto kernel
            fi
            if [ -z "$(ip -6 ru list pref 3000)" ]; then
              ip -6 ru add pref 3000 lookup local proto kernel
            fi
          '';
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          after = [ "network-pre.target" ];
          before = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
        };

        systemd.network.enable = true;

        systemd.network.config.networkConfig.ManageForeignRoutes = false;

        systemd.network.netdevs = {
          gravity = {
            netdevConfig = { Kind = "vrf"; Name = "gravity"; };
            vrfConfig = { Table = cfg.table + 0; };
          };
        } // (if cfg.exit.enable then {
          vethGravity = {
            netdevConfig = { Kind = "veth"; Name = "veth-gravity"; };
            peerConfig = { Name = "veth-global"; };
          };
          vethGlobal = {
            netdevConfig = { Kind = "veth"; Name = "veth-global"; };
            peerConfig = { Name = "veth-gravity"; };
          };
        } else { });

        systemd.network.networks = {
          gravity = {
            name = config.systemd.network.netdevs.gravity.netdevConfig.Name;
            linkConfig.RequiredForOnline = false;
            addresses = map
              (addr6: {
                addressConfig = {
                  Address = addr6;
                  AddPrefixRoute = false;
                };
              })
              cfg.address;
            routes = map
              (addr6: {
                # fallback route
                routeConfig = {
                  Destination = addr6;
                  Type = "local";
                  Metric = 8;
                };
              })
              cfg.address;
          };
        } // (if cfg.exit.enable then {
          vethGravity = {
            name = config.systemd.network.netdevs.vethGravity.netdevConfig.Name;
            linkConfig.RequiredForOnline = false;
            vrf = [ "gravity" ];
          };
          vethGlobal = {
            name = config.systemd.network.netdevs.vethGlobal.netdevConfig.Name;
            linkConfig.RequiredForOnline = false;
          };
        } else { });
      }
      (mkIf (cfg.wireguard.enable) {
        environment.systemPackages = with pkgs; [
          wireguard-tools
          ranet.packages.x86_64-linux.default
        ];

        environment.etc."ranet/config.json".text = builtins.toJSON {
          vrf = "gravity";
          mtu = 1400;
          prefix = "ranet";
          fwmark = 447;
          stale_group = 1;
          active_group = 2;
          address = cfg.wireguard.prefix;
          peers = map
            (peer: {
              public_key = peer.publicKey;
              address_family = peer.addressFamily;
              endpoint = peer.endpoint;
              send_port = peer.sendPort;
              persistent_keepalive = peer.persistentKeepalive;
            })
            cfg.wireguard.peers;
        };

        systemd.services.gravity = {
          path = [ ranet.packages.x86_64-linux.default ];
          script = "ranet -c /etc/ranet/config.json -k ${cfg.wireguard.privateKeyPath} up";
          reload = "ranet -c /etc/ranet/config.json -k ${cfg.wireguard.privateKeyPath} up";
          preStop = "ranet -c /etc/ranet/config.json -k ${cfg.wireguard.privateKeyPath} down";
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
          reloadTriggers = [ config.environment.etc."ranet/config.json".source ];
        };
      })
      (mkIf cfg.bird.enable {
        services.bird2 = {
          enable = true;
          config = ''
            protocol device {
              scan time 5;
            }
            ipv6 sadr table gravity6;
            protocol kernel {
              kernel table ${toString cfg.table};
              ipv6 sadr {
                table gravity6;
                export all;
                import none;
              };
            }
            protocol static {
              ipv6 sadr { table gravity6; };
              ${concatStringsSep "\n" (map (addr6: ''
                route ${addr6} from ::/0 via "gravity";
              '') cfg.address)}
              ${concatStringsSep "\n" (map (addr6: ''
                route ${addr6} from ::/0 unreachable;
              '') cfg.bird.routes)}
              ${optionalString (cfg.exit.enable && cfg.exit.type != "customer") ''
                route fd82:7565:0f3a::/48 from ::/0 unreachable;
                ${optionalString (cfg.exit.routeAll.enable) ''
                  ${concatStringsSep "\n" (map (addr6: ''
                    route ::/0 from ${addr6} via fe80:: dev "veth-gravity";
                  '') cfg.exit.routeAll.allow)}
                ''}
              ''}
              ${optionalString (cfg.exit.enable) ''
                ${concatStringsSep "\n" (map (addr6: ''
                  route ${addr6} from ::/0 via fe80:: dev "veth-gravity";
                '') cfg.exit.routes)}
              ''}
            }
            protocol babel {
              vrf "gravity";
              ipv6 sadr {
                table gravity6;
                export all;
                import all;
              };
              randomize router id;
              interface "ranet*" {
                type tunnel;
                link quality etx;
                rxcost 32;
                rtt cost 1024;
                rtt max 1024 ms;
                rx buffer 2000;
              };
              ${optionalString (cfg.exit.enable && cfg.exit.type == "customer") ''
              interface "veth-gravity" {
                type wired;
                rxcost 32;
              };
              ''}
            }
            ${optionalString (cfg.exit.enable && cfg.exit.type != "customer") ''
            ipv6 table global6;
            protocol static {
              ipv6 { table global6; };
              route fd82:7565:0f3a::/48 via fe80:: dev "veth-global";
            }
            protocol kernel {
              metric 4096;
              ipv6 {
                table global6;
                export all;
                import none;
              };
            }
            ''}
            ${optionalString (cfg.exit.enable && cfg.exit.type == "customer") ''
            ipv6 sadr table global6;
            protocol static {
              ipv6 sadr { table global6; };
              ${concatStringsSep "\n" (map (addr6: ''
                route ${addr6} from ::/0 unreachable;
              '') cfg.exit.routes)}
            }
            protocol kernel {
              metric 4096;
              ipv6 sadr {
                table global6;
                export all;
                import none;
              };
            }
            protocol babel {
              ipv6 sadr {
                table global6;
                export all;
                import all;
              };
              randomize router id;
              interface "veth-global" {
                type wired;
                rxcost 32;
              };
            }
            ''}
          '';
        };
      })
      (mkIf cfg.nptv6.enable {
        networking.nftables = {
          enable = true;
          tables = {
            nptv6 = {
              family = "ip6";
              content = ''
                define bogon = {${lib.concatStringsSep "," myvars.constants.bogonAddresses.ipv6}}

                chain raw {
                  type filter hook prerouting priority raw; policy accept;
                  ${concatStringsSep "\n" (map (data: ''
                    ip6 saddr ${data.source} notrack return
                    ip6 daddr ${data.target} notrack return
                  '') cfg.nptv6.maps)}
                }

                chain prerouting {
                  type filter hook prerouting priority dstnat + 1; policy accept;
                  ${concatStringsSep "\n" (map (data: ''
                    iifname ${cfg.nptv6.oif} ip6 daddr ${data.target} counter ip6 daddr set ${data.source}
                  '') cfg.nptv6.maps)}
                }

                chain postrouting {
                  type filter hook postrouting priority srcnat + 1; policy accept;
                  ${concatStringsSep "\n" (map (data: ''
                    oifname ${cfg.nptv6.oif} ip6 saddr ${data.source} counter ip6 saddr set ${data.target}
                  '') cfg.nptv6.maps)}
                  oifname ${cfg.nptv6.oif} ip6 saddr $bogon counter drop
                }
              '';
            };
          };
        };
      })
    ]
  );
}
