{ self, mylib, config, mysecrets, myvars, ... }:
let
  hostName = "flandre-eq59";
  homeNetwork = myvars.networks.homeNetwork;
  localNode = homeNetwork.nodes.${hostName};
in
{
  imports =
    [
      self.nixosModules.default
      mysecrets.nixosModules.secrets.flandre
    ]
    ++ (mylib.getItemPaths ./. "default.nix");

  custom = {
    baseline.enable = true;
    system.disko.btrfs-uefi-common = {
      enable = true;
      device = "/dev/disk/by-path/pci-0000:00:17.0-ata-1";
    };
  };

  i18n.defaultLocale = "en_SG.UTF-8";
  time.timeZone = "Asia/Shanghai";

  networking = {
    inherit hostName;
    wireless.iwd.enable = true;
  };

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
      "20-enp2s0" = {
        name = "enp2s0";
        bridge = [ "brlan" ];
      };
      "20-enp3s0" = {
        name = "enp3s0";
        bridge = [ "brwan" ];
      };
      "20-brlan" = {
        name = "brlan";
        address = [ localNode.ipv4 ];
        gateway = [ (mylib.networking.ipv4.cidrToIpAddress homeNetwork.gateway.ipv4) ];
        dns = [ (mylib.networking.ipv4.cidrToIpAddress homeNetwork.nameserver.ipv4) ];
      };
      "20-brwan" = {
        name = "brwan";
        networkConfig = {
          LinkLocalAddressing = "no";
          IPv6AcceptRA = "no";
        };
      };
      "30-wlan0" = {
        name = "wlan0";
        DHCP = "yes";
      };
    };
  };

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = mysecrets.sshPublicKeys;

  services.caddy.enable = true;
  systemd.services.caddy.serviceConfig.LoadCredential = [
    "cert:${mysecrets.certificates.server}"
    "key:${config.sops.secrets.certificate-server-key.path}"
  ];

  system.stateVersion = "23.11";
}
