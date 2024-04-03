{ config, lib, ... }:
with lib; let
  cfg = config.custom.programs.wayland.swaylock;
in
{
  options.custom.programs.wayland.swaylock = {
    enable = mkEnableOption "screen locker for wayland";
  };

  config = mkIf cfg.enable {
    programs.swaylock = {
      enable = true;
      settings = {
        show-failed-attempts = true;
        daemonize = true;
        color = "000000";
      };
    };
  };
}
