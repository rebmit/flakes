{ config, ... }: {
  services.gitea = {
    enable = true;
    lfs.enable = true;
    database.type = "postgres";
    appName = "Gitea";
    settings = {
      server = {
        DOMAIN = "gitea.rebmit.internal";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 10001;
        ROOT_URL = "http://gitea.rebmit.internal";
      };
    };
  };

  services.caddy = {
    virtualHosts."gitea.rebmit.internal".extraConfig = ''
      tls "/run/credentials/caddy.service/cert" "/run/credentials/caddy.service/key"
      reverse_proxy ${config.services.gitea.settings.server.HTTP_ADDR}:${toString config.services.gitea.settings.server.HTTP_PORT}
    '';
  };
}
