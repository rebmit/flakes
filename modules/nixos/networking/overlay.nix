{ config, pkgs, lib, myvars, ... }:
with lib;
let
  cfg = config.custom.networking.overlay;
in
{
  options.custom.networking.overlay = {
    enable = mkEnableOption ''
      declarative overlay network based on wireguard, heavily inspired by
      <https://github.com/NickCao/flakes/blob/master/modules/gravity/default.nix>
    '';
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
          hostName = config.networking.hostName;
        in
        {
          custom.networking.overlay = {
            address = [
              (myvars.networks.overlayNetwork.nodes."${hostName}".ipv4)
              (myvars.networks.overlayNetwork.nodes."${hostName}".ipv6)
            ];
          };
        }
      ))
    ]
  );
}
