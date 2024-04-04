{ pkgs, config, lib, mylib, ... } @ args:
with lib; let
  cfg = config.custom.services.desktopEnvironment.hyprland;
  startupCommand = mkOption {
    type = types.str;
    example = "kitty";
  };
  windowRegex = mkOption {
    type = types.str;
    example = "class: ^(kitty)$";
  };
  scratchpadOpts = { name, ... }: {
    options = {
      inherit startupCommand windowRegex;
      keyBind = mkOption {
        type = types.str;
        example = "SUPER, 1";
      };
    };
  };
  browserOpts = { ... }: {
    options = {
      inherit startupCommand windowRegex;
    };
  };
  terminalOpts = { ... }: {
    options = {
      inherit startupCommand windowRegex;
      launchPrefix = mkOption {
        type = types.str;
        example = "kitty -e";
      };
    };
  };
in
{
  options.custom.services.desktopEnvironment.hyprland = {
    enable = mkEnableOption "desktop environment based on hyprland";
    settings = mkOption {
      type = with types; let
        valueType =
          nullOr
            (oneOf [
              bool
              int
              float
              str
              path
              (attrsOf valueType)
              (listOf valueType)
            ])
          // {
            description = "Hyprland configuration value";
          };
      in
      valueType;
      default = { };
    };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };
    scratchpads = mkOption {
      type = with types; attrsOf (submodule scratchpadOpts);
      default = { };
    };
    browser = mkOption { type = types.submodule browserOpts; };
    terminal = mkOption { type = types.submodule terminalOpts; };
  };

  config = mkIf cfg.enable (
    mkMerge ([
      {
        wayland.windowManager.hyprland.settings = cfg.settings;
        wayland.windowManager.hyprland.extraConfig = cfg.extraConfig;
      }
      {
        home.packages = with pkgs; [
          systemd-run-app
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
        };

        wayland.windowManager.hyprland = {
          enable = true;
          systemd.enable = true;
        };
      }
    ] ++ (map (path: import path args) (mylib.getItemPaths ./. "default.nix")))
  );
}