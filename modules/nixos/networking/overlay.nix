{ config, pkgs, lib, myvars, ranet, ... }:
with lib;
let
  cfg = config.custom.networking.overlay;
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
  stateful = config.systemd.network.netdevs.stateful.vrfConfig.Table;
  stateles = config.systemd.network.netdevs.stateles.vrfConfig.Table;
in
{
  options.custom.networking.overlay = {
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
      mtu = mkOption {
        type = types.int;
        default = 1400;
        description = "interface mtu";
      };
      firewallMark = mkOption {
        type = types.int;
        default = 447;
        description = "wireguard fwmark for all interfaces";
      };
      interfacePrefix = mkOption {
        type = types.str;
        default = "ranet";
        description = "prefix of interface name";
      };
      peers = mkOption {
        type = with types; listOf (submodule peerOpts);
        default = { };
        description = "remote peers of the local node";
      };
      staleGroup = mkOption {
        type = types.int;
        default = 1;
        description = "group id for stale interfaces";
      };
      activeGroup = mkOption {
        type = types.int;
        default = 2;
        description = "group id for active interfaces";
      };
    };
    table = mkOption {
      type = types.int;
      default = 2000;
      description = "routing table number for the vrf interfaces";
    };
    address4 = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "list of ipv4 addresses to be added to the vrf interfaces";
    };
    address6 = mkOption {
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
      exit = {
        enable = mkEnableOption "exit node";
        overlayNetwork4 = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "ipv4 prefix of the overlay network";
        };
        overlayNetwork6 = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "ipv6 prefix of the overlay network";
        };
        globalNetwork4 = mkOption {
          type = types.listOf types.str;
          default = cfg.bird.exit.overlayNetwork4;
          description = "ipv4 prefix of the global network";
        };
        globalNetwork6 = mkOption {
          type = types.listOf types.str;
          default = cfg.bird.exit.overlayNetwork6;
          description = "ipv6 prefix of the global network";
        };
        prefix4 = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "ipv4 prefix to be announced for local node";
        };
        prefix6 = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "ipv6 prefix to be announced for local node";
        };
      };
      pattern = mkOption {
        type = types.str;
        default = "ranet*";
        description = "pattern for wireguard interfaces";
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

        environment.etc."iproute2/rt_tables.d/overlay.conf" = {
          mode = "0644";
          text = ''
            ${toString cfg.table} overlay
            ${toString stateles} stateles
            ${toString stateful} stateful
          '';
        };

        systemd.services.overlay-rules = {
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
          overlay = {
            netdevConfig = { Kind = "vrf"; Name = "overlay"; };
            vrfConfig = { Table = cfg.table + 0; };
          };
          stateful = {
            netdevConfig = { Kind = "vrf"; Name = "stateful"; };
            vrfConfig = { Table = cfg.table + 1; };
          };
          stateles = {
            netdevConfig = { Kind = "vrf"; Name = "stateles"; };
            vrfConfig = { Table = cfg.table + 2; };
          };
        };

        systemd.network.networks = {
          overlay = {
            name = config.systemd.network.netdevs.overlay.netdevConfig.Name;
            address = cfg.address4 ++ cfg.address6;
            linkConfig.RequiredForOnline = false;
          };
          stateful = {
            name = config.systemd.network.netdevs.stateful.netdevConfig.Name;
            linkConfig.RequiredForOnline = false;
          };
          stateles = {
            name = config.systemd.network.netdevs.stateles.netdevConfig.Name;
            linkConfig.RequiredForOnline = false;
          };
        };
      }
      (mkIf (cfg.wireguard.enable) {
        environment.systemPackages = with pkgs; [
          wireguard-tools
          ranet.packages.x86_64-linux.default
        ];

        environment.etc."ranet/config.json".text = builtins.toJSON {
          vrf = "overlay";
          mtu = cfg.wireguard.mtu;
          prefix = cfg.wireguard.interfacePrefix;
          fwmark = cfg.wireguard.firewallMark;
          stale_group = cfg.wireguard.staleGroup;
          active_group = cfg.wireguard.activeGroup;
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

        systemd.services.overlay = {
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
            ipv4 table overlay4;
            ipv6 sadr table overlay6;
            protocol device {
              scan time 5;
            }
            ${optionalString cfg.bird.exit.enable ''
            ipv4 table stateles4;
            ipv6 table stateles6;
            ipv4 table stateful4;
            ipv6 table stateful6;
            protocol pipe stateles4_pipe {
              table stateles4;
              peer table master4;
              import all;
              export none;
            }
            protocol pipe stateles6_pipe {
              table stateles6;
              peer table master6;
              import all;
              export none;
            }
            protocol pipe stateful4_pipe {
              table stateful4;
              peer table master4;
              import all;
              export none;
            }
            protocol pipe stateful6_pipe {
              table stateful6;
              peer table master6;
              import all;
              export none;
            }
            protocol kernel stateles4_kern {
              kernel table ${toString stateles};
              ipv4 {
                table stateles4;
                import none;
                export all;
              };
            }
            protocol kernel stateles6_kern {
              kernel table ${toString stateles};
              ipv6 {
                table stateles6;
                import none;
                export all;
              };
            }
            protocol kernel stateful4_kern {
              kernel table ${toString stateful};
              ipv4 {
                table stateful4;
                import none;
                export all;
              };
            }
            protocol kernel stateful6_kern {
              kernel table ${toString stateful};
              ipv6 {
                table stateful6;
                import none;
                export all;
              };
            }
            protocol kernel {
              ipv4 {
                table master4;
                export where proto = "announce4";
                import all;
              };
              learn;
            }
            protocol kernel {
              ipv6 {
                table master6;
                export where proto = "announce6";
                import all;
              };
              learn;
            }
            ''}
            protocol kernel {
              kernel table ${toString cfg.table};
              ipv4 {
                table overlay4;
                export all;
                import none;
              };
            }
            protocol kernel {
              kernel table ${toString cfg.table};
              ipv6 sadr {
                table overlay6;
                export all;
                import none;
              };
            }
            protocol static {
              ipv4 { table overlay4; };
              ${concatStringsSep "\n" (map (addr4: ''
                route ${addr4} via "overlay";
              '') cfg.address4)}
              ${optionalString cfg.bird.exit.enable ''
                ${concatStringsSep "\n" (map (addr4: ''
                route ${addr4} via "stateles";
                '') cfg.bird.exit.prefix4)}
                ${concatStringsSep "\n" (map (addr4: ''
                route ${addr4} unreachable;
                '') cfg.bird.exit.overlayNetwork4)}
              ''}
            }
            protocol static {
              ipv6 sadr { table overlay6; };
              ${concatStringsSep "\n" (map (addr6: ''
                route ${addr6} from ::/0 via "overlay";
              '') cfg.address6)}
              ${optionalString cfg.bird.exit.enable ''
                ${concatStringsSep "\n" (map (addr6: ''
                route ${addr6} from ::/0 via "stateles";
                '') cfg.bird.exit.prefix6)}
                ${concatStringsSep "\n" (map (addr6: ''
                route ${addr6} from ::/0 unreachable;
                '') cfg.bird.exit.overlayNetwork6)}
              ''}
            }
            protocol babel {
              vrf "overlay";
              ipv4 {
                table overlay4;
                export all;
                import all;
              };
              ipv6 sadr {
                table overlay6;
                export all;
                import all;
              };
              randomize router id;
              interface "${cfg.bird.pattern}" {
                type tunnel;
                link quality etx;
                rxcost 32;
                hello interval 20 s;
                rtt cost 1024;
                rtt max 1024 ms;
                rx buffer 2000;
              };
            }
            ${optionalString cfg.bird.exit.enable ''
            protocol static announce4 {
              ipv4 { table master4; };
              ${concatStringsSep "\n" (map (addr4: ''
              route ${addr4} via "overlay";
              '') cfg.bird.exit.globalNetwork4)}
            }
            protocol static announce6 {
              ipv6 { table master6; };
              ${concatStringsSep "\n" (map (addr6: ''
              route ${addr6} via "overlay";
              '') cfg.bird.exit.globalNetwork6)}
            }
            ''}
          '';
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
          getGlobalAddresses = addressFamily: (
            builtins.concatLists (builtins.attrValues (lib.mapAttrs'
              (name: value: {
                inherit name;
                value =
                  if addressFamily == "ip4" then
                    value.advertiseRoutes.ipv4
                  else
                    value.advertiseRoutes.ipv6;
              })
              myvars.networks
            ))
          );
        in
        {
          custom.networking.overlay = {
            address4 = overlayNetwork.nodes."${hostName}".ipv4;
            address6 = overlayNetwork.nodes."${hostName}".ipv6;
            wireguard = {
              enable = true;
              privateKeyPath = config.sops.secrets.overlay-wireguard-privatekey.path;
              inherit (overlayNetwork.meta.wireguard) mtu interfacePrefix firewallMark;
              inherit peers;
            };
            bird = rec {
              enable = true;
              pattern = "${cfg.wireguard.interfacePrefix}*";
              exit.enable = true;
              exit.prefix4 = overlayNetwork.nodes."${hostName}".routes4;
              exit.prefix6 = overlayNetwork.nodes."${hostName}".routes6;
              exit.overlayNetwork4 = overlayNetwork.advertiseRoutes.ipv4;
              exit.overlayNetwork6 = overlayNetwork.advertiseRoutes.ipv6;
              exit.globalNetwork4 = builtins.filter (x: !(builtins.elem x exit.prefix4)) (getGlobalAddresses "ip4");
              exit.globalNetwork6 = builtins.filter (x: !(builtins.elem x exit.prefix6)) (getGlobalAddresses "ip6");
            };
          };
        }
      ))
    ]
  );
}
