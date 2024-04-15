{ config, ... }:
let
  serviceDomain = "gitea.rebmit.internal";
in
{
  services.gitea = {
    enable = true;
    lfs.enable = true;
    database.type = "postgres";
    appName = "Gitea";
    settings = {
      server = {
        DOMAIN = "${serviceDomain}";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 10001;
        ROOT_URL = "https://${serviceDomain}";
      };
    };
  };

  services.caddy = {
    virtualHosts."${serviceDomain}".extraConfig = ''
      tls /run/credentials/caddy.service/cert /run/credentials/caddy.service/key
      reverse_proxy ${config.services.gitea.settings.server.HTTP_ADDR}:${toString config.services.gitea.settings.server.HTTP_PORT}
    '';
  };
}
