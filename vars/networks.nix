{ mysecrets, ... }:
rec {
  overlayNetwork =
    let
      prefix6 = "fd82:7565:0f3a:891b";
      overlayNetworkSecrets = mysecrets.data.networks.overlayNetwork;
      generateNode = hostName: data: {
        inherit (data) ipv6 prefix;
        inherit (overlayNetworkSecrets.nodes.${hostName}) meta;
        fqdn = "${hostName}.link.rebmit.internal";
        ipv4 = [ ];
        routes4 = (data.routes4 or [ ]) ++ (overlayNetworkSecrets.nodes.${hostName}.routes4 or [ ]);
        routes6 = (data.routes6 or [ ]) ++ (overlayNetworkSecrets.nodes.${hostName}.routes6 or [ ]);
      };
      generateLink = addressFamily: srcName: destName: { inherit addressFamily srcName destName; };
    in
    {
      advertiseRoutes = {
        ipv4 = [ ];
        ipv6 = [ "${prefix6}::/64" ];
      };

      nodes = {
        reisen-nrt0 = generateNode "reisen-nrt0" {
          prefix = "${prefix6}:031d";
          ipv6 = [ "${prefix6}:031d::1/128" ];
        };
        reisen-sin0 = generateNode "reisen-sin0" {
          prefix = "${prefix6}:6eda";
          ipv6 = [ "${prefix6}:6eda::1/128" ];
        };
        misaka-lax02 = generateNode "misaka-lax02" {
          prefix = "${prefix6}:9920";
          ipv6 = [ "${prefix6}:9920::1/128" ];
        };
        flandre-eq59 = generateNode "flandre-eq59" {
          prefix = "${prefix6}:73aa";
          ipv6 = [ "${prefix6}:73aa::1/128" ];
          routes4 = homeNetwork.advertiseRoutes.ipv4;
          routes6 = homeNetwork.advertiseRoutes.ipv6;
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

      inherit (overlayNetworkSecrets) meta;
    };

  homeNetwork =
    let
      prefix6 = "fd82:7565:0f3a:89ac";
    in
    rec {
      advertiseRoutes = {
        ipv4 = [ "10.224.0.0/20" ];
        ipv6 = [ "${prefix6}::/64" ];
      };

      nodes = {
        flandre-eq59 = {
          fqdn = "flandre-eq59.link.rebmit.internal";
          ipv4 = "10.224.0.1/20";
          ipv6 = "${prefix6}:abc4::1/64";
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
          ipv6 = "${prefix6}:1ae9::1/64";
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
