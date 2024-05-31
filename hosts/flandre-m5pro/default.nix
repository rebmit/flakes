{ mylib, mysecrets, lib, ... }:
let
  hostName = "flandre-m5pro";
in
{
  imports = mylib.getItemPaths ./. "default.nix";

  custom = {
    baseline.enable = true;
    system.disko.btrfs-uefi-common = {
      enable = true;
      device = "/dev/disk/by-path/pci-0000:05:00.1-ata-1";
    };
  };

  boot.loader = {
    efi.canTouchEfiVariables = false;
    systemd-boot.enable = lib.mkDefault true;
  };

  i18n.defaultLocale = "en_SG.UTF-8";
  time.timeZone = "Asia/Shanghai";

  networking = { inherit hostName; };

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = mysecrets.sshPublicKeys;

  environment.persistence."/persist" = {
    files = [
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
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

  system.stateVersion = "23.11";
}
