{ config, lib, ... }:
with lib; let
  cfg = config.custom.services.wayland.cliphist;
in
{
  options.custom.services.wayland.cliphist = {
    enable = mkEnableOption "a clipboard history manager for wayland";
  };

  config = mkIf cfg.enable {
    services.cliphist.enable = true;
  };
}
