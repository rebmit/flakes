{ config, lib, pkgs, ... }:
with lib; let
  cfg = config.custom.programs.thunderbird;
in
{
  options.custom.programs.thunderbird = {
    enable = mkEnableOption "thunderbird email";
  };

  config = mkIf cfg.enable {
    home.persistence."/persist/home/${config.home.username}" = {
      directories = [
        ".thunderbird"
      ];
    };

    home.packages = with pkgs; [
      thunderbird
    ];
  };
}
