{ config, pkgs, lib, mylib, ... } @ args:
with lib; let
  cfg = config.custom.programs.wayland.waybar;
in
{
  options.custom.programs.wayland.waybar = {
    enable = mkEnableOption "highly customizable wayland bar for sway and wlroots based compositors.";
  };

  config = mkIf cfg.enable (
    mkMerge ([
      {
        programs.waybar = {
          enable = true;
          settings = [ (import ./waybar.nix { inherit pkgs config; }) ];
          systemd.enable = true;
        };
      }
    ] ++ (map (path: import path args) (mylib.getItemPaths ./. [ "default.nix" "waybar.nix" ])))
  );
}
