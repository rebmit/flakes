{ mylib, lib }: rec {
  homeNetwork = {
    advertiseRoutes = {
      ipv4 = [ "10.224.0.0/20" ];
    };

    nodes = {
      flandre-eq59 = {
        fqdn = "flandre-eq59.link.rebmit.internal";
        ipv4 = "10.224.0.1/20";
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

    nameserver = homeNetwork.nodes.flandre-eq59-smartdns;
    gateway = homeNetwork.nodes.flandre-eq59-gateway;
  };
}
