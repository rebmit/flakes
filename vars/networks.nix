{ mysecrets, ... }:
let
  generateLink = addressFamily: srcName: destName: { inherit addressFamily srcName destName; };
  overlayNetworkMeta = mysecrets.data.networks.overlayNetwork;
in
rec {
  overlayNetwork = {
    advertiseRoutes = {
      ipv4 = [ "100.64.0.0/16" ];
      ipv6 = [ "fd82:7565:0f3a:891b::/64" ];
    };

    nodes = {
      reisen-nrt0 = {
        fqdn = "reisen-nrt0.link.rebmit.internal";
        ipv4 = [ "100.64.0.1/32" ];
        ipv6 = [ "fd82:7565:0f3a:891b:8d3a:6b73:fcca:49bf/128" ];
        routes4 = [ ];
        routes6 = [ ];
        inherit (overlayNetworkMeta.nodes.reisen-nrt0) meta;
      };
      reisen-sin0 = {
        fqdn = "reisen-sin0.link.rebmit.internal";
        ipv4 = [ "100.64.0.2/32" ];
        ipv6 = [ "fd82:7565:0f3a:891b:d2f0:d353:9cf6:22c8/128" ];
        routes4 = [ ];
        routes6 = [ ];
        inherit (overlayNetworkMeta.nodes.reisen-sin0) meta;
      };
      misaka-lax02 = {
        fqdn = "misaka-lax02.link.rebmit.internal";
        ipv4 = [ "100.64.0.3/32" ];
        ipv6 = [ "fd82:7565:0f3a:891b:16c6:3874:2e4e:d07a/128" ];
        routes4 = [ ];
        routes6 = [ ];
        inherit (overlayNetworkMeta.nodes.misaka-lax02) meta;
      };
      flandre-eq59 = {
        fqdn = "flandre-eq59.link.rebmit.internal";
        ipv4 = [ "100.64.1.1/32" ];
        ipv6 = [ "fd82:7565:0f3a:891b:05ce:6285:094d:d50c/128" ];
        routes4 = homeNetwork.advertiseRoutes.ipv4;
        routes6 = homeNetwork.advertiseRoutes.ipv6;
        inherit (overlayNetworkMeta.nodes.flandre-eq59) meta;
      };
    };

    links = [
      (generateLink "ip4" "reisen-nrt0" "reisen-sin0")
      (generateLink "ip6" "reisen-nrt0" "reisen-sin0")
      (generateLink "ip4" "reisen-nrt0" "misaka-lax02")
      (generateLink "ip6" "reisen-nrt0" "misaka-lax02")
      (generateLink "ip4" "reisen-sin0" "misaka-lax02")
      (generateLink "ip6" "reisen-sin0" "misaka-lax02")
      (generateLink "ip4" "flandre-eq59" "reisen-nrt0")
      (generateLink "ip4" "flandre-eq59" "reisen-sin0")
    ];

    inherit (overlayNetworkMeta) meta;
  };

  homeNetwork = rec {
    advertiseRoutes = {
      ipv4 = [ "10.224.0.0/20" ];
      ipv6 = [ "fd82:7565:0f3a:89ac::/64" ];
    };

    nodes = {
      flandre-eq59 = {
        fqdn = "flandre-eq59.link.rebmit.internal";
        ipv4 = "10.224.0.1/20";
        ipv6 = "fd82:7565:0f3a:89ac:abc4:6e63:b46f:4575/64";
      };
      flandre-eq59-router = {
        fqdn = "flandre-eq59-router.link.rebmit.internal";
        ipv4 = "10.224.0.2/20";
      };
      flandre-eq59-smartdns = {
        fqdn = "flandre-eq59-smartdns.link.rebmit.internal";
        ipv4 = "10.224.0.3/20";
      };
      flandre-eq59-mihomo = {
        fqdn = "flandre-eq59-mihomo.link.rebmit.internal";
        ipv4 = "10.224.0.4/20";
      };
      flandre-eq59-gateway = {
        fqdn = "flandre-eq59-gateway.link.rebmit.internal";
        ipv4 = "10.224.0.5/20";
      };
      marisa-7d76 = {
        fqdn = "marisa-7d76.link.rebmit.internal";
        ipv4 = "10.224.14.1/20";
      };
    };

    nameserver = nodes.flandre-eq59-smartdns;
    gateway = nodes.flandre-eq59-gateway;

    dhcp4 = {
      subnet = "10.224.0.0/20";
      pools = [
        {
          pool = "10.224.15.1 - 10.224.15.254";
        }
      ];
    };
  };
}
