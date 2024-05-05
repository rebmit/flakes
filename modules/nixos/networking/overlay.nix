{ config, pkgs, lib, myvars, ... }:
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
    };
    table = mkOption {
      type = types.int;
      default = 2000;
      description = "routing table number for the vrf interfaces";
    };
    address = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "list of addresses to be added to the vrf interfaces";
    };
    preset = mkOption {
      type = types.bool;
      default = true;
      description = "whether to use preset configratuion based on myvars";
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
        };

        systemd.network.networks = {
          overlay = {
            name = config.systemd.network.netdevs.overlay.netdevConfig.Name;
            address = cfg.address;
            linkConfig.RequiredForOnline = false;
          };
        };
      }
      (mkIf (cfg.preset) (
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
          custom.networking.overlay = {
            address = [
              (overlayNetwork.nodes."${hostName}".ipv4)
              (overlayNetwork.nodes."${hostName}".ipv6)
            ];
            wireguard = {
              enable = true;
              privateKeyPath = config.sops.secrets.overlay-wireguard-privatekey.path;
              inherit (overlayNetwork.meta.wireguard) mtu interfacePrefix firewallMark;
              inherit peers;
            };
          };
        }
      ))
    ]
  );
}
