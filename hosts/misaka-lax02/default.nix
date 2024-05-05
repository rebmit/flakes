{ mysecrets, self, mylib, ... }: {
  imports =
    [
      self.nixosModules.default
      mysecrets.nixosModules.secrets.misaka
    ]
    ++ (mylib.getItemPaths ./. "default.nix");

  custom = {
    cloud.misaka.enable = true;
    networking.overlay.enable = true;
  };

  networking.hostName = "misaka-lax02";

  services.caddy = {
    virtualHosts."rebmit.moe".extraConfig = ''
      header /.well-known/matrix/* Content-Type application/json
      header /.well-known/matrix/* Access-Control-Allow-Origin *
      respond /.well-known/matrix/server `{"m.server": "matrix.rebmit.moe:443"}`
      respond /.well-known/matrix/client `{"m.homeserver":{"base_url":"https://matrix.rebmit.moe"}}`
    '';
  };

  system.stateVersion = "23.11";
}
