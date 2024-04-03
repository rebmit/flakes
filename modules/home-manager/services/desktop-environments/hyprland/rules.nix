{ config, lib, ... }:
with lib; let
  cfg = config.custom.services.desktopEnvironment.hyprland;
  renderScratchpad = name: cfg: ''
    windowrulev2 = workspace special:${name}, ${cfg.windowRegex}
    workspace = special:${name}, gapsin:5, gapsout:75, on-created-empty:systemd-run-app ${cfg.startupCommand}
  '';
in
{
  wayland.windowManager.hyprland.extraConfig = ''
    windowrulev2 = workspace 1, ${cfg.terminal.windowRegex}
    windowrulev2 = workspace 2, ${cfg.browser.windowRegex}
    ${concatStringsSep "\n" (mapAttrsToList renderScratchpad cfg.scratchpads)}
  '';
}
