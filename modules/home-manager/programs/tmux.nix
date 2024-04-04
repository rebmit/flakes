{ pkgs, config, lib, ... }:
with lib; let
  cfg = config.custom.programs.tmux;
in
{
  options.custom.programs.tmux = {
    enable = mkEnableOption "terminal multiplexer";
    shell = mkOption {
      type = types.str;
      default = "${pkgs.fish}/bin/fish";
    };
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      baseIndex = 1;
      escapeTime = 10;
      keyMode = "vi";
      mouse = true;
      shell = "${cfg.shell}";
      terminal = "screen-256color";
      extraConfig = ''
        set -g allow-passthrough on
        set -ga update-environment TERM
        set -ga update-environment TERM_PROGRAM
        new-session -s main
      '';
    };
  };
}
