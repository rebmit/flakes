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
      inputs.sops-nix.nixosModules.sops
    ]
    ++ (mylib.getItemPaths ./. "default.nix");

  preset = {
    baseline = {
      enable = true;
      uefi = false;
    };
  };

  sops = {
    defaultSopsFile = ./secrets.yml;
    age = {
      keyFile = "/persist/_data/sops.key";
      sshKeyPaths = [];
    };
    gnupg.sshKeyPaths = [];
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

  services.caddy = {
    enable = true;
    virtualHosts."rebmit.moe".extraConfig = ''
      header /.well-known/matrix/* Content-Type application/json
      header /.well-known/matrix/* Access-Control-Allow-Origin *
      respond /.well-known/matrix/server `{"m.server": "matrix.rebmit.moe:443"}`
      respond /.well-known/matrix/client `{"m.homeserver":{"base_url":"https://matrix.rebmit.moe"}}`
    '';
  };

  system.stateVersion = "23.11";
}
