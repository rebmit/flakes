{ pkgs, config, ... }:
let
  cfg = config.custom.services.desktopEnvironment.hyprland;
  scratchpadHelper = pkgs.writeShellApplication {
    name = "hyprland-scratchpad-helper";
    text = ''
      function handle {
        case "$1" in
          "activespecial>>"*)
            echo "$1"
            workspace=$(echo "$1" | sed 's/activespecial>>//g' | cut -d "," -f 1)
            if [[ -z "$workspace" ]]; then
              hyprctl dispatch submap reset
            elif [[ "$workspace" != "special" ]]; then
              hyprctl dispatch submap scratchpad
            fi
          ;;
        esac
      }

      ${pkgs.socat}/bin/socat -U - "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line
      do
        handle "$line"
      done
    '';
  };
in
{
  wayland.windowManager.hyprland.extraConfig = ''
    # https://discourse.nixos.org/t/clicked-links-in-desktop-apps-not-opening-browers/29114/4
    exec-once = systemctl --user import-environment PATH && systemctl --user restart xdg-desktop-portal.service
    exec-once = hyprctl setcursor capitaine-cursors 36
    exec-once = swww init
    exec-once = systemd-run-app ags
    exec-once = ${scratchpadHelper}/bin/hyprland-scratchpad-helper
    exec-once = systemd-run-app ${cfg.terminal.startupCommand}
    exec-once = systemd-run-app ${cfg.browser.startupCommand}
  '';
}
