{ self, mylib, data, config, inputs, ... }: {
  imports =
    [
      self.nixosModules.default
      inputs.mysecrets.nixosModules.secrets.flandre
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
    hostName = "flandre-eq59";
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
        address = [ "10.224.0.1/20" ];
        gateway = [ "10.224.0.2" ];
        dns = [ "10.224.0.3" ];
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
  users.users.root.openssh.authorizedKeys.keys = data.keys;

  services.caddy.enable = true;
  systemd.services.caddy.serviceConfig.LoadCredential = [
    "cert:${inputs.mysecrets.certificates.server}"
    "key:${config.sops.secrets.certificate-server-key.path}"
  ];

  system.stateVersion = "23.11";
}
