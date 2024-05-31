{ mysecrets, ... }: {
  overlayNetwork =
    let
      prefix6 = "fd82:7565:0f3a:891b";
      overlayNetworkSecrets = mysecrets.data.networks.overlayNetwork;
    in
    {
      advertiseRoutes = {
        ipv4 = [ ];
        ipv6 = [ "${prefix6}::/64" ];
      };

      nodes = {
        reisen-nrt0 = {
          prefix = "${prefix6}:031d";
          fqdn = "reisen-nrt0.link.rebmit.internal";
          ipv4 = [ ];
          ipv6 = [ "${prefix6}:031d::1/128" ];
          inherit (overlayNetworkSecrets.nodes.reisen-nrt0) meta;
        };
        reisen-sin0 = {
          prefix = "${prefix6}:6eda";
          fqdn = "reisen-sin0.link.rebmit.internal";
          ipv4 = [ ];
          ipv6 = [ "${prefix6}:6eda::1/128" ];
          inherit (overlayNetworkSecrets.nodes.reisen-sin0) meta;
        };
        misaka-lax02 = {
          prefix = "${prefix6}:9920";
          fqdn = "misaka-lax02.link.rebmit.internal";
          ipv4 = [ ];
          ipv6 = [ "${prefix6}:9920::1/128" ];
          inherit (overlayNetworkSecrets.nodes.misaka-lax02) meta;
        };
      };

      links = [
        { addressFamily = "ip4"; srcName = "reisen-nrt0"; destName = "reisen-sin0"; }
        { addressFamily = "ip6"; srcName = "reisen-nrt0"; destName = "reisen-sin0"; }
        { addressFamily = "ip4"; srcName = "reisen-nrt0"; destName = "misaka-lax02"; }
        { addressFamily = "ip6"; srcName = "reisen-nrt0"; destName = "misaka-lax02"; }
        { addressFamily = "ip4"; srcName = "reisen-sin0"; destName = "misaka-lax02"; }
        { addressFamily = "ip6"; srcName = "reisen-sin0"; destName = "misaka-lax02"; }
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
        marisa-7d76 = {
          fqdn = "marisa-7d76.link.rebmit.internal";
          ipv4 = "10.224.14.1/20";
          ipv6 = "${prefix6}:1ae9::1/64";
        };
      };

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
