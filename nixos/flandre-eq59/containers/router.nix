{ lib, ... }: {
  containers."router" = {
    autoStart = true;
    privateNetwork = true;
    extraVeths = {
      lan.hostBridge = "brlan";
      wan.hostBridge = "brwan";
    };
    config = {
      networking = {
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      systemd.network = {
        enable = true;
        wait-online.enable = false;
        networks = {
          "20-wan" = {
            name = "wan";
            networkConfig = {
              DHCP = "ipv4";
              IPv6AcceptRA = "no";
            };
            dhcpV4Config = {
              SendHostname = false;
              UseDNS = false;
              UseRoutes = false;
              UseGateway = false;
              RouteTable = 200;
              RouteMetric = 2048;
            };
            routes = [
              {
                routeConfig = {
                  Table = 200;
                  Gateway = "_dhcp4";
                  Destination = "172.16.0.0/12";
                };
              }
              {
                routeConfig = {
                  Table = 200;
                  Gateway = "_dhcp4";
                  Destination = "192.168.0.0/16";
                };
              }
            ];
            routingPolicyRules = [
              {
                routingPolicyRuleConfig = {
                  Table = 200;
                  Priority = 20000;
                };
              }
            ];
          };
          "20-lan" = {
            name = "lan";
            addresses = [
              {
                addressConfig = {
                  Address = "10.224.0.2/20";
                  AddPrefixRoute = false;
                };
              }
            ];
            networkConfig = {
              DHCP = "no";
              IPv6AcceptRA = "no";
            };
            routes = [
              {
                routeConfig = {
                  Table = 150;
                  Destination = "10.224.0.2/20";
                };
              }
            ];
            routingPolicyRules = [
              {
                routingPolicyRuleConfig = {
                  Table = 150;
                  Priority = 15000;
                };
              }
            ];
          };
        };
      };

      services.resolved.enable = true;

      system.stateVersion = "23.11";
    };
  };
}
