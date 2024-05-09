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
    preset = mkOption {
      type = types.bool;
      default = true;
      description = "whether to use preset configratuion based on myvars";
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
      routes = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "ipv6 routes outside the vrf to be announced for local node";
      };
      network = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "ipv6 prefix of the overlay network";
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
            ${optionalString cfg.exit.enable ''
            ipv6 sadr table global6;
            ''}
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
              ${optionalString cfg.exit.enable ''
                ${concatStringsSep "\n" (map (addr6: ''
                  route ${addr6} from ::/0 via fe80:: dev "veth-gravity";
                '') cfg.exit.routes)}
                ${concatStringsSep "\n" (map (addr6: ''
                  route ${addr6} from ::/0 unreachable;
                '') cfg.exit.network)}
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
              ${optionalString cfg.exit.enable ''
              interface "veth-gravity" {
                type wired;
                rxcost 32;
              };
              ''}
            }
            ${optionalString cfg.exit.enable ''
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
                }
              '';
            };
          };
        };
      })
      (mkIf cfg.preset (
        let
          overlayNetwork = myvars.networks.overlayNetwork;
          hostName = config.networking.hostName;
          getAddrByFamily = nodeName: addressFamily:
            if addressFamily == "ip4" then
              overlayNetwork.nodes."${nodeName}".meta.wireguard.publicIpv4
            else
              overlayNetwork.nodes."${nodeName}".meta.wireguard.publicIpv6;
          links = builtins.filter
            (value: value.srcName == hostName)
            (
              lists.imap0
                (index: value:
                  rec {
                    inherit (value) addressFamily;
                    sendPort = overlayNetwork.meta.wireguard.basePort + index;
                    persistentKeepalive =
                      let
                        srcAddr = getAddrByFamily value.srcName addressFamily;
                        destAddr = getAddrByFamily value.destName addressFamily;
                      in
                      if srcAddr == null || destAddr == null then 25 else null;
                  } // (if (value.destName == hostName) then {
                    srcName = value.destName;
                    destName = value.srcName;
                  } else {
                    inherit (value) srcName destName;
                  })
                )
                myvars.networks.overlayNetwork.links
            );
          peers = builtins.map
            (link: rec {
              inherit (link) sendPort addressFamily persistentKeepalive;
              publicKey = overlayNetwork.nodes."${link.destName}".meta.wireguard.publicKey;
              endpoint =
                let
                  address = getAddrByFamily link.destName addressFamily;
                in
                if address == null then null else "${address}:${toString sendPort}";
            })
            links;
        in
        {
          custom.networking.gravity = {
            address = overlayNetwork.nodes."${hostName}".ipv6;
            wireguard = {
              enable = true;
              privateKeyPath = config.sops.secrets.overlay-wireguard-privatekey.path;
              inherit peers;
              prefix = "${overlayNetwork.nodes."${hostName}".prefix}:ffff::/96";
            };
            bird = {
              enable = true;
              routes = [ "${overlayNetwork.nodes."${hostName}".prefix}::/80" ];
            };
            exit = {
              enable = true;
              routes = overlayNetwork.nodes."${hostName}".routes6;
              network = overlayNetwork.advertiseRoutes.ipv6;
            };
          };
        }
      ))
    ]
  );
}
