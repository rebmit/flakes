{ config, myvars, mylib, ... }:
let
  hostName = config.networking.hostName;
  inherit (myvars.networks) overlayNetwork;
in
{
  custom.networking.gravity = {
    enable = true;
    address = overlayNetwork.nodes."${hostName}".ipv6;
    wireguard = {
      enable = true;
      privateKeyPath = config.sops.secrets.overlay-wireguard-privatekey.path;
      prefix = "${overlayNetwork.nodes."${hostName}".prefix}:ffff::/96";
      peers = mylib.networking.wireguard.getPeers overlayNetwork hostName;
    };
    bird = {
      enable = true;
      routes = [ "${overlayNetwork.nodes."${hostName}".prefix}::/80" ];
    };
    exit = {
      enable = true;
      type = "transit";
      routes = [ "${overlayNetwork.nodes.${hostName}.meta.wireguard.publicIpv6}/128" ];
      routeAll = {
        enable = true;
        allow = myvars.networks.overlayNetwork.advertiseRoutes.ipv6
          ++ myvars.networks.homeNetwork.advertiseRoutes.ipv6;
      };
    };
    nptv6 = {
      enable = true;
      maps = [
        { source = "fd82:7565:0f3a:89ac::/64"; target = "${overlayNetwork.nodes.${hostName}.meta.prefix}ac::/64"; }
        { source = "fd82:7565:0f3a:891b::/64"; target = "${overlayNetwork.nodes.${hostName}.meta.prefix}1b::/64"; }
      ];
    };
  };
}
