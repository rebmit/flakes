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

  system.stateVersion = "23.11";
}
