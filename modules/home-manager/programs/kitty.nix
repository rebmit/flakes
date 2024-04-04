{ config, lib, ... }:
with lib; let
  cfg = config.custom.programs.kitty;
in
{
  options.custom.programs.kitty = {
    enable = mkEnableOption "cross-platform, fast, feature-rich, gpu based terminal";
    shell = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font = {
        name = "monospace";
        size = 12.0;
      };
      settings = {
        shell = "${cfg.shell}";
        window_padding_width = "0";
        window_border_width = "0";
        background_opacity = "0.9";
        hide_window_decorations = "yes";
        confirm_os_window_close = "0";
        enable_audio_bell = "no";
        window_alert_on_bell = "no";
        map = "kitty_mod+t no_op";

        foreground = "#${config.colorScheme.palette.base05}";
        background = "#${config.colorScheme.palette.base00}";
        color0 = "#${config.colorScheme.palette.base00}";
        color1 = "#${config.colorScheme.palette.base08}";
        color2 = "#${config.colorScheme.palette.base0B}";
        color3 = "#${config.colorScheme.palette.base0A}";
        color4 = "#${config.colorScheme.palette.base0D}";
        color5 = "#${config.colorScheme.palette.base0E}";
        color6 = "#${config.colorScheme.palette.base0C}";
        color7 = "#${config.colorScheme.palette.base05}";
        color8 = "#${config.colorScheme.palette.base03}";
        color9 = "#${config.colorScheme.palette.base08}";
        color10 = "#${config.colorScheme.palette.base0B}";
        color11 = "#${config.colorScheme.palette.base0A}";
        color12 = "#${config.colorScheme.palette.base0D}";
        color13 = "#${config.colorScheme.palette.base0E}";
        color14 = "#${config.colorScheme.palette.base0C}";
        color15 = "#${config.colorScheme.palette.base07}";
      };
    };
  };
}
