{ config, ... }: {
  systemd.network = {
    enable = true;
    wait-online.enable = false;
    netdevs = {
      "20-brlan" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "brlan";
        };
      };
      "20-brwan" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "brwan";
        };
      };
    };
    networks = {
      "20-enp1s0" = {
        name = "enp1s0";
        bridge = [ "brlan" ];
      };
      "20-enp2s0" = {
        name = "enp2s0";
        bridge = [ "brwan" ];
      };
      "30-brlan" = {
        name = "brlan";
        address = [ "fd82:7565:0f3a:89ac:e6fd::1/64" ];
      };
    };
  };
}
