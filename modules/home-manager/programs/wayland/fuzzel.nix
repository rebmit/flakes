{ pkgs, config, lib, ... }:
with lib; let
  cfg = config.custom.programs.wayland.fuzzel;
in
{
  options.custom.programs.wayland.fuzzel = {
    enable = mkEnableOption "application launcher for wlroots based wayland compositors";
    terminal = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      systemd-run-app
    ];

    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "monospace";
          terminal = cfg.terminal;
          layer = "overlay";
          launch-prefix = "systemd-run-app";
        };
        colors = {
          background = "${config.colorScheme.palette.base00}ee";
          text = "${config.colorScheme.palette.base05}ff";
          match = "${config.colorScheme.palette.base0D}ff";
          selection = "${config.colorScheme.palette.base04}ff";
          selection-text = "${config.colorScheme.palette.base05}ff";
          selection-match = "${config.colorScheme.palette.base0D}ff";
          border = "${config.colorScheme.palette.base0D}ff";
        };
        border = {
          width = "2";
          radius = "0";
        };
      };
    };
  };
}
