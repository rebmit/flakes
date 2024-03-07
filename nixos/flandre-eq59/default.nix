{
  config,
  lib,
  pkgs,
  inputs,
  self,
  mylib,
  data,
  ...
}: {
  imports =
    [
      self.nixosModules.default
    ]
    ++ (mylib.getItemPaths ./. "default.nix");

  preset = {
    baseline.enable = true;
  };

  nix.settings.trusted-users = ["root"];

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
    };
    networks = {
      "20-enp2s0" = {
        matchConfig.Name = "enp2s0";
        networkConfig.Bridge = "brlan";
      };
      "20-enp3s0" = {
        matchConfig.Name = "enp3s0";
      };
      "20-brlan" = {
        matchConfig.Name = "brlan";
        address = ["10.224.0.1/20"];
      };
    };
  };

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = data.keys;

  system.stateVersion = "23.11";
}
