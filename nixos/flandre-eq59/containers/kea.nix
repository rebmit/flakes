{ lib, ... }: {
  custom.containers."kea" = {
    autoStart = true;
    privateNetwork = true;
    ephemeral = true;
    extraVeths."kea-lan".hostBridge = "brlan";
    config = {
      networking = {
        useHostResolvConf = lib.mkForce false;
        firewall.enable = false;
      };

      services.resolved.enable = lib.mkForce false;

      systemd.network = {
        enable = true;
        wait-online.enable = false;
        networks = {
          "20-lan" = {
            name = "kea-lan";
            address = [ "10.224.0.4/20" ];
          };
        };
      };

      services.kea.dhcp4 = {
        enable = true;
        settings = {
          interfaces-config.interfaces = [ "kea-lan" ];
          lease-database = {
            name = "/var/lib/kea/dhcp4.leases";
            persist = true;
            type = "memfile";
          };
          rebind-timer = 2000;
          renew-timer = 1000;
          subnet4 = [
            {
              pools = [
                {
                  pool = "10.224.15.1 - 10.224.15.254";
                }
              ];
              subnet = "10.224.0.0/20";
              option-data = [
                {
                  name = "routers";
                  data = "10.224.0.2";
                }
                {
                  name = "domain-name-servers";
                  data = "10.224.0.3";
                }
              ];
            }
          ];
          valid-lifetime = 4000;
        };
      };

      system.stateVersion = "23.11";
    };
  };
}
