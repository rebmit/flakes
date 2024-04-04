{ config, lib, ... }:
with lib; let
  cfg = config.custom.programs.yazi;
in
{
  options.custom.programs.yazi = {
    enable = mkEnableOption "blazing fast terminal file manager written in rust";
    enableFishIntegration = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.fish.interactiveShellInit = mkIf cfg.enableFishIntegration ''
      function yazi
        set tmp (mktemp -t "yazi-cwd.XXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
          echo "switching working directory to $cwd"
          cd -- "$cwd"
        end
        rm -f -- "$tmp"
      end
      alias ra yazi
    '';

    programs.yazi = {
      enable = true;
      settings = {
        manager = {
          ratio = [ 1 4 3 ];
          sort_by = "natural";
          sort_sensitive = false;
          sort_reverse = false;
          sort_dir_first = true;
          linemode = "size";
          show_hidden = false;
          show_symlink = true;
        };
        preview = {
          tab_size = 2;
          max_width = 1000;
          max_height = 1000;
        };
      };
    };
  };
}
