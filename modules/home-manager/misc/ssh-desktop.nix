{ lib, mysecrets, config, ... }:
with lib;
let
  cfg = config.custom.misc.ssh-desktop;
  remoteHosts = mysecrets.remoteHosts;
  configurations = attrValues (mapAttrs
    (name: host: {
      xdg.desktopEntries."ssh-desktop-${name}" = {
        name = "[ssh] ${name}";
        exec = "${cfg.terminal} -e bash -c \"env TERM=xterm-256color ssh -p ${host.port} ${host.user}@${host.host}; echo Exited; read\"";
      };
    })
    remoteHosts);
in
{
  options.custom.misc.ssh-desktop = {
    enable = mkEnableOption "generate desktop file for remote ssh hosts";
    terminal = mkOption {
      type = types.str;
      example = "kitty";
    };
  };

  config = mkIf cfg.enable (mkMerge configurations);
}
