{ pkgs, config, ... }:
let
  cfg = config.custom.services.desktopEnvironment.hyprland;
in
{
  wayland.windowManager.hyprland.extraConfig = ''
    # https://discourse.nixos.org/t/clicked-links-in-desktop-apps-not-opening-browers/29114/4
    exec-once = systemctl --user import-environment PATH && systemctl --user restart xdg-desktop-portal.service
    exec-once = hyprctl setcursor capitaine-cursors 36
    exec-once = swww init
    exec-once = systemd-run-app ags
    exec-once = ${pkgs.hyprland-scratchpad-helper}/bin/hyprland-scratchpad-helper
    exec-once = systemd-run-app ${cfg.terminal.startupCommand}
    exec-once = systemd-run-app ${cfg.browser.startupCommand}
  '';
}
