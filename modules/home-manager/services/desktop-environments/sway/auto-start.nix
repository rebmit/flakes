{ config, ... }:
let
  cfg = config.custom.services.desktopEnvironment.sway;
in
{
  wayland.windowManager.sway.config.startup = [
    { command = "systemctl --user import-environment PATH && systemctl --user restart xdg-desktop-portal.service"; }
    { command = "swww-daemon --format xrgb"; }
    { command = "systemd-run-app ags"; }
    { command = "systemd-run-app ${cfg.terminal.startupCommand}"; }
    { command = "systemd-run-app ${cfg.browser.startupCommand}"; }
  ];
}
