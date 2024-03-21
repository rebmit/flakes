{ ... }: {
  wayland.windowManager.hyprland.extraConfig = ''
    # https://discourse.nixos.org/t/clicked-links-in-desktop-apps-not-opening-browers/29114/4
    exec-once = systemctl --user import-environment PATH && systemctl --user restart xdg-desktop-portal.service
    exec-once = hyprctl setcursor capitaine-cursors 36
    exec-once = swww init
    exec-once = hyprland-scratchpad-helper
    exec-once = systemd-run-app ags
    exec-once = systemd-run-app kitty
    exec-once = systemd-run-app firefox
  '';
}
