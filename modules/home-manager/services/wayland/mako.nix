{ pkgs, config, lib, ... }:
with lib; let
  cfg = config.custom.services.wayland.mako;
in
{
  options.custom.services.wayland.mako = {
    enable = mkEnableOption "a lightweight notification daemon for wayland";
  };

  config = mkIf cfg.enable {
    services.mako = {
      enable = true;
      extraConfig = ''
        background-color=#${config.colorScheme.palette.base00}
        text-color=#${config.colorScheme.palette.base05}
        border-color=#${config.colorScheme.palette.base0D}
        on-button-right=exec makoctl menu -n "$id" ${pkgs.fuzzel}/bin/fuzzel -dmenu -p 'action: '
        [urgency=low]
        border-color=#${config.colorScheme.palette.base0D}
        [urgency=normal]
        border-color=#${config.colorScheme.palette.base0D}
        [urgency=high]
        border-color=#${config.colorScheme.palette.base08}
      '';
    };
  };
}
