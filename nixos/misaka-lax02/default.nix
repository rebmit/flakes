{ pkgs, inputs, self, mylib, data, ... }: {
  imports =
    [
      self.nixosModules.default
      inputs.mysecrets.nixosModules.secrets.misaka
    ]
    ++ (mylib.getItemPaths ./. "default.nix");

  custom.baseline = {
    enable = true;
    uefi = false;
  };

  networking.hostName = "misaka-lax02";

  systemd.network = {
    enable = true;
    wait-online.enable = false;
    networks = {
      "20-wired" = {
        matchConfig.Name = [ "en*" "eth*" ];
        DHCP = "yes";
      };
    };
  };

  services.openssh.enable = true;
  services.openssh.ports = [ 2222 ];
  services.openssh.settings.PasswordAuthentication = false;
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
