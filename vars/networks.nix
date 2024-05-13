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
        konpaku-fra0 = {
          prefix = "${prefix6}:346a";
          fqdn = "konpaku-fra0.link.rebmit.internal";
          ipv4 = [ ];
          ipv6 = [ "${prefix6}:346a::1/128" ];
          inherit (overlayNetworkSecrets.nodes.konpaku-fra0) meta;
        };
        flandre-eq59 = {
          prefix = "${prefix6}:73aa";
          fqdn = "flandre-eq59.link.rebmit.internal";
          ipv4 = [ ];
          ipv6 = [ "${prefix6}:73aa::1/128" ];
          inherit (overlayNetworkSecrets.nodes.flandre-eq59) meta;
        };
      };

      links = [
        { addressFamily = "ip4"; srcName = "reisen-nrt0"; destName = "reisen-sin0"; }
        { addressFamily = "ip6"; srcName = "reisen-nrt0"; destName = "reisen-sin0"; }
        { addressFamily = "ip4"; srcName = "reisen-nrt0"; destName = "misaka-lax02"; }
        { addressFamily = "ip6"; srcName = "reisen-nrt0"; destName = "misaka-lax02"; }
        { addressFamily = "ip4"; srcName = "reisen-sin0"; destName = "misaka-lax02"; }
        { addressFamily = "ip6"; srcName = "reisen-sin0"; destName = "misaka-lax02"; }
        { addressFamily = "ip4"; srcName = "flandre-eq59"; destName = "reisen-nrt0"; }
        { addressFamily = "ip4"; srcName = "flandre-eq59"; destName = "reisen-sin0"; }
        { addressFamily = "ip4"; srcName = "reisen-nrt0"; destName = "konpaku-fra0"; }
        { addressFamily = "ip6"; srcName = "reisen-nrt0"; destName = "konpaku-fra0"; }
        { addressFamily = "ip4"; srcName = "reisen-sin0"; destName = "konpaku-fra0"; }
        { addressFamily = "ip6"; srcName = "reisen-sin0"; destName = "konpaku-fra0"; }
        { addressFamily = "ip4"; srcName = "misaka-lax02"; destName = "konpaku-fra0"; }
        { addressFamily = "ip6"; srcName = "misaka-lax02"; destName = "konpaku-fra0"; }
        { addressFamily = "ip4"; srcName = "flandre-eq59"; destName = "konpaku-fra0"; }
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
