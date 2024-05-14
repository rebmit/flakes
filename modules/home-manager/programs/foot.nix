{ config, lib, ... }:
with lib; let
  cfg = config.custom.programs.foot;
in
{
  options.custom.programs.foot = {
    enable = mkEnableOption "a fast, lightweight and minimalistic wayland terminal emulator";
    shell = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    programs.foot = {
      enable = true;
      settings = {
        main = {
          shell = cfg.shell;
          font = "monospace:size=11.5";
          dpi-aware = "yes";
        };
        colors = {
          alpha = "0.95";
          foreground = "${config.colorScheme.palette.base05}";
          background = "${config.colorScheme.palette.base00}";
          regular0 = "${config.colorScheme.palette.base00}";
          regular1 = "${config.colorScheme.palette.base08}";
          regular2 = "${config.colorScheme.palette.base0B}";
          regular3 = "${config.colorScheme.palette.base0A}";
          regular4 = "${config.colorScheme.palette.base0D}";
          regular5 = "${config.colorScheme.palette.base0E}";
          regular6 = "${config.colorScheme.palette.base0C}";
          regular7 = "${config.colorScheme.palette.base05}";
          bright0 = "${config.colorScheme.palette.base03}";
          bright1 = "${config.colorScheme.palette.base08}";
          bright2 = "${config.colorScheme.palette.base0B}";
          bright3 = "${config.colorScheme.palette.base0A}";
          bright4 = "${config.colorScheme.palette.base0D}";
          bright5 = "${config.colorScheme.palette.base0E}";
          bright6 = "${config.colorScheme.palette.base0C}";
          bright7 = "${config.colorScheme.palette.base07}";
        };
        mouse = {
          hide-when-typing = "yes";
        };
      };
    };
  };
}
