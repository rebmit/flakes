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
      exit = {
        enable = mkEnableOption "exit node";
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
          vethGravity = {
            netdevConfig = { Kind = "veth"; Name = "veth-gravity"; };
            peerConfig = { Name = "veth-global"; };
          };
          vethGlobal = {
            netdevConfig = { Kind = "veth"; Name = "veth-global"; };
            peerConfig = { Name = "veth-gravity"; };
          };
        };

        systemd.network.networks = {
          gravity = {
            name = config.systemd.network.netdevs.gravity.netdevConfig.Name;
            linkConfig.RequiredForOnline = false;
          };
          vethGravity = {
            name = config.systemd.network.netdevs.vethGravity.netdevConfig.Name;
            address = cfg.address4 ++ cfg.address6;
            linkConfig.RequiredForOnline = false;
            vrf = [ "gravity" ];
          };
          vethGlobal = {
            name = config.systemd.network.netdevs.vethGlobal.netdevConfig.Name;
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
          vrf = "gravity";
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
            ipv4 table gravity4;
            ipv6 sadr table gravity6;
            protocol kernel {
              kernel table ${toString cfg.table};
              ipv4 {
                table gravity4;
                export all;
                import none;
              };
            }
            protocol kernel {
              kernel table ${toString cfg.table};
              ipv6 sadr {
                table gravity6;
                export all;
                import none;
              };
            }
            protocol static {
              ipv4 { table gravity4; };
              ${concatStringsSep "\n" (map (addr4: ''
                route ${addr4} via "veth-gravity";
              '') cfg.address4)}
              ${concatStringsSep "\n" (map (addr4: ''
                route ${addr4} unreachable;
              '') cfg.bird.overlayNetwork4)}
            }
            protocol static {
              ipv6 sadr { table gravity6; };
              ${concatStringsSep "\n" (map (addr6: ''
                route ${addr6} from ::/0 via "veth-gravity";
              '') cfg.address6)}
              ${concatStringsSep "\n" (map (addr6: ''
                route ${addr6} from ::/0 unreachable;
              '') cfg.bird.overlayNetwork6)}
            }
            protocol babel {
              vrf "gravity";
              ipv4 {
                table gravity4;
                export all;
                import all;
              };
              ipv6 sadr {
                table gravity6;
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
              interface "veth-gravity" {
                type wired;
                rxcost 32;
                hello interval 20 s;
              };
            }
            protocol kernel {
              learn all;
              ipv4 {
                table master4;
                export all;
                import filter {
                  ${concatStringsSep "\n" (map (addr4: ''
                    if net = ${addr4} then accept;
                  '') cfg.bird.prefix4)}
                  reject;
                };
              };
            }
            protocol kernel {
              learn all;
              ipv6 {
                table master6;
                export all;
                import filter {
                  ${concatStringsSep "\n" (map (addr6: ''
                    if net = ${addr6} then accept;
                  '') cfg.bird.prefix6)}
                  reject;
                };
              };
            }
            protocol babel {
              ipv4 {
                table master4;
                export all;
                import all;
              };
              ipv6 {
                table master6;
                export all;
                import all;
              };
              randomize router id;
              interface "veth-global" {
                type wired;
                rxcost 32;
                hello interval 20 s;
              };
            }
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
        in
        {
          custom.networking.gravity = {
            address4 = overlayNetwork.nodes."${hostName}".ipv4;
            address6 = overlayNetwork.nodes."${hostName}".ipv6;
            wireguard = {
              enable = true;
              privateKeyPath = config.sops.secrets.overlay-wireguard-privatekey.path;
              inherit (overlayNetwork.meta.wireguard) mtu interfacePrefix firewallMark;
              inherit peers;
            };
            bird = {
              enable = true;
              pattern = "${cfg.wireguard.interfacePrefix}*";
              prefix4 = overlayNetwork.nodes."${hostName}".routes4;
              prefix6 = overlayNetwork.nodes."${hostName}".routes6;
              overlayNetwork4 = overlayNetwork.advertiseRoutes.ipv4;
              overlayNetwork6 = overlayNetwork.advertiseRoutes.ipv6;
              exit = {
                enable = false;
              };
            };
          };
        }
      ))
    ]
  );
}
