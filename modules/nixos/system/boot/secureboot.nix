{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.custom.system.boot.secureboot;
in
with lib; {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

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
  };
}
