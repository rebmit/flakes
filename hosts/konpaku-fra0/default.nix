{ mylib, mysecrets, myvars, ... }:
let
  hostName = "konpaku-fra0";
  inherit (myvars.networks) overlayNetwork;
in
{
  imports =
    [
      mysecrets.nixosModules.secrets.konpaku-fra0
      mysecrets.nixosModules.networks.konpaku-fra0
    ]
    ++ (mylib.getItemPaths ./. "default.nix");

  custom.cloud.hcloud.enable = true;

  networking = {
    inherit hostName;
  };

  systemd.network = {
    enable = true;
    networks = {
      "20-wired" = {
        matchConfig.Name = [ "en*" "eth*" "ens*" ];
        address = [
          (overlayNetwork.nodes.${hostName}.meta.ip4)
          (overlayNetwork.nodes.${hostName}.meta.ip6)
        ];
        dns = [ "1.1.1.1" ];
        routes = [
          { routeConfig = { Destination = overlayNetwork.nodes.${hostName}.meta.gateway4; }; }
          { routeConfig = { Gateway = overlayNetwork.nodes.${hostName}.meta.gateway4; GatewayOnLink = true; }; }
          { routeConfig = { Destination = overlayNetwork.nodes.${hostName}.meta.gateway6; }; }
          { routeConfig = { Gateway = overlayNetwork.nodes.${hostName}.meta.gateway6; GatewayOnLink = true; }; }
        ];
        networkConfig = {
          DHCP = "no";
          KeepConfiguration = "yes";
          IPv6AcceptRA = "yes";
          IPv6PrivacyExtensions = "no";
        };
      };
    };
  };

  system.stateVersion = "23.11";
}
