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
    baseline = {
      enable = true;
      uefi = false;
    };
  };

  networking.hostName = "misaka-lax02";

  systemd.network = {
    enable = true;
    wait-online.enable = false;
    networks = {
      "20-wired" = {
        matchConfig.Name = ["en*" "eth*"];
        DHCP = "yes";
        networkConfig = {
          KeepConfiguration = "yes";
          IPv6AcceptRA = "yes";
          IPv6PrivacyExtensions = "no";
        };
      };
    };
  };

  services.openssh.enable = true;
  services.openssh.ports = [2222];
  users.users.root.openssh.authorizedKeys.keys = data.keys;

  system.stateVersion = "23.11";
}
