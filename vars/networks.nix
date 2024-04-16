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
      flandre-eq59-wireguard = {
        fqdn = "flandre-eq59-wireguard.link.rebmit.internal";
        ipv4 = "10.224.0.6/20";
      };
      marisa-7d76 = {
        fqdn = "marisa-7d76.link.rebmit.internal";
        ipv4 = "10.224.14.1/20";
      };
    };

    nameserver = homeNetwork.nodes.flandre-eq59-smartdns;
    gateway = homeNetwork.nodes.flandre-eq59-gateway;

    dhcp4 = {
      subnet = "10.224.0.0/20";
      pools = [
        {
          pool = "10.224.15.1 - 10.224.15.254";
        }
      ];
    };
  };

  constants = {
    privateAddresses = {
      ipv4 = [
        "10.0.0.0/8"
        "100.64.0.0/10"
        "127.0.0.0/8"
        "169.254.0.0/16"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "224.0.0.0/4"
        "240.0.0.0/4"
        "255.255.255.255/32"
      ];
    };
  };
}
