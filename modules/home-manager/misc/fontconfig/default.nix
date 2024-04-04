{ pkgs, config, lib, ... }:
with lib; let
  cfg = config.custom.misc.fontconfig;
in
{
  options.custom.misc.fontconfig = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
    fontPackages = mkOption {
      default = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-emoji
        roboto-mono
        (nerdfonts.override { fonts = [ "RobotoMono" ]; })
      ];
    };
    fontConfig = mkOption {
      default = ./fonts.conf;
    };
  };

  config = mkIf cfg.enable {
    home.packages = cfg.fontPackages;

    xdg.configFile."fontconfig/fonts.conf".source = cfg.fontConfig;
    fonts.fontconfig.enable = true;
  };
}
