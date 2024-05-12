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

  networking.nftables = {
    enable = true;
    tables = {
      spdlimit = {
        family = "ip6";
        content = ''
          limit download { rate over 6400 kbytes/second }
          limit upload   { rate over 3200 kbytes/second burst 512 kbytes }

          chain postrouting {
            type filter hook postrouting priority filter; policy accept;
            oifname "ranet*" limit name "upload" counter drop
          }
          chain prerouting {
            type filter hook prerouting priority filter; policy accept;
            iifname "ranet*" limit name "download" counter drop
          }
        '';
      };
    };
  };
}
