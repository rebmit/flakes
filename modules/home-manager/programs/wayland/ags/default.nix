{ config, lib, inputs, mylib, ... } @ args:
with lib; let
  cfg = config.custom.programs.wayland.ags;
in
{
  options.custom.programs.wayland.ags = {
    enable = mkEnableOption "aylur's gtk shell";
  };

  config = mkIf cfg.enable (
    mkMerge ([
      {
        xdg.configFile."ags/components" = {
          source = ./components;
          recursive = true;
        };

        xdg.configFile."ags/config.js" = {
          source = ./config.js;
        };

        programs.ags.enable = true;
      }
    ] ++ (map (path: import path args) (mylib.getItemPaths ./. "default.nix")))
  );
}
