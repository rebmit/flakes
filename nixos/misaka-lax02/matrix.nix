{
  config,
  pkgs,
  ...
}: let
  conf = {
    default_server_config = {
      "m.homeserver" = {
        base_url = config.services.matrix-synapse.settings.public_baseurl;
        server_name = config.services.matrix-synapse.settings.server_name;
      };
    };
    show_labs_settings = true;
  };
in {
  sops = {
    secrets = {
      matrix-synapse = {owner = config.systemd.services.matrix-synapse.serviceConfig.User;};
    };
  };

  services.matrix-synapse = {
    enable = true;
    withJemalloc = true;
    settings = {
      server_name = "rebmit.moe";
      public_baseurl = "https://matrix.rebmit.moe";
      signing_key_path = config.sops.secrets.matrix-synapse.path;

      enable_registration = true;
      registration_requires_token = true;

      listeners = [
        {
          bind_addresses = ["127.0.0.1"];
          port = 8196;
          tls = false;
          type = "http";
          x_forwarded = true;
          resources = [
            {
              compress = true;
              names = ["client" "federation"];
            }
          ];
        }
      ];

      media_retention = {
        remote_media_lifetime = "14d";
      };

      experimental_features = {
        # Room summary api
        msc3266_enabled = true;
        # Removing account data
        msc3391_enabled = true;
        # Thread notifications
        msc3773_enabled = true;
        # Remotely toggle push notifications for another client
        msc3881_enabled = true;
        # Remotely silence local notifications
        msc3890_enabled = true;
      };
    };
  };

  services.caddy = {
    virtualHosts."matrix.rebmit.moe".extraConfig = ''
      reverse_proxy /_matrix/* 127.0.0.1:8196
      reverse_proxy /_synapse/client/* 127.0.0.1:8196

      header {
        X-Frame-Options SAMEORIGIN
        X-Content-Type-Options nosniff
        X-XSS-Protection "1; mode=block"
        Content-Security-Policy "frame-ancestors 'self'"
      }

      file_server
      root * "${pkgs.element-web.override {inherit conf;}}"
    '';
  };
}
