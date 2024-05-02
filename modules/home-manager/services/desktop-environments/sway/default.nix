{ pkgs, config, lib, mylib, ... } @ args:
with lib; let
  cfg = config.custom.services.desktopEnvironment.sway;
  startupCommand = mkOption { };
  windowCriteria = mkOption { };
  browserOpts = { ... }: {
    options = {
      inherit startupCommand windowCriteria;
    };
  };
  terminalOpts = { ... }: {
    options = {
      inherit startupCommand windowCriteria;
      launchPrefix = mkOption { };
    };
  };
in
{
  options.custom.services.desktopEnvironment.sway = {
    enable = mkEnableOption "desktop environment based on sway";
    package = mkOption {
      default = pkgs.sway;
    };
    config = mkOption { };
    browser = mkOption { type = types.submodule browserOpts; };
    terminal = mkOption { type = types.submodule terminalOpts; };
  };

  config = mkIf cfg.enable (
    mkMerge ([
      {
        wayland.windowManager.sway.package = cfg.package;
        wayland.windowManager.sway.config = cfg.config;
      }
      {
        home.packages = with pkgs; [
          systemd-run-app
          swww
        ];

        custom.services.wayland = {
          mako.enable = true;
          cliphist.enable = true;
        };

        custom.programs.wayland = {
          fuzzel = {
            enable = true;
            terminal = cfg.terminal.launchPrefix;
          };
          swaylock.enable = true;
          waybar.enable = true;
        };

        wayland.windowManager.sway = {
          enable = true;
          systemd = {
            enable = true;
            xdgAutostart = true;
          };
          wrapperFeatures.gtk = true;
          config = {
            modifier = "Mod4";
            terminal = "systemd-run-app ${cfg.terminal.startupCommand}";
          };
        };
      }
    ] ++ (map (path: import path args) (mylib.getItemPaths ./. "default.nix")))
  );
}
