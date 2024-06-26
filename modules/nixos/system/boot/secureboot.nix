{ config, pkgs, lib, ... }:
let
  cfg = config.custom.system.boot.secureboot;
in
with lib; {
  options.custom.system.boot.secureboot = {
    enable = mkEnableOption "lanzaboote secureboot";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sbctl
    ];

    boot.loader.systemd-boot.enable = lib.mkForce false;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };

    environment.persistence."/persist" = {
      directories = [
        "/etc/secureboot"
      ];
    };
  };
}
