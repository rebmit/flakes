{ mylib, config, myvars, ... }:
let
  hostName = config.networking.hostName;
  inherit (myvars.networks) homeNetwork overlayNetwork;
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
      type = "customer";
      routes = homeNetwork.advertiseRoutes.ipv6;
    };
  };
}
