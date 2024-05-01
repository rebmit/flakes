{ config, ... }:
let
  serviceDomain = "ntfy.rebmit.moe";
in
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://${serviceDomain}";
      listen-http = "";
      listen-unix = "/run/ntfy-sh/ntfy.sock";
      listen-unix-mode = 511; # 0777
      behind-proxy = true;
    };
  };

  systemd.services.ntfy-sh.serviceConfig.RuntimeDirectory = [ "ntfy-sh" ];

  services.caddy.virtualHosts."${serviceDomain}" = {
    extraConfig = ''
      reverse_proxy unix/${config.services.ntfy-sh.settings.listen-unix}
    '';
  };
}
