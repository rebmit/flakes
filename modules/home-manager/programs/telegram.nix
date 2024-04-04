{ pkgs, config, lib, ... }:
with lib; let
  cfg = config.custom.programs.telegram;
in
{
  options.custom.programs.telegram = {
    enable = mkEnableOption "telegram client for linux";
    package = mkOption {
      type = types.package;
      default = pkgs.telegram-desktop-megumifox;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # fix auto-night mode
    xdg.desktopEntries."org.telegram.desktop" = {
      name = "Telegram Desktop";
      icon = "telegram";
      exec = "env QT_QPA_PLATFORMTHEME=gtk3 telegram-desktop -- %u";
    };
  };
}
