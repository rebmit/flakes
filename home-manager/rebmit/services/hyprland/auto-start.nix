{...}: {
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      # https://discourse.nixos.org/t/clicked-links-in-desktop-apps-not-opening-browers/29114/4
      "systemctl --user import-environment PATH && systemctl --user restart xdg-desktop-portal.service"

      "hyprctl setcursor capitaine-cursors 36"
      "swww init"
      "systemd-run-app ags"
    ];
  };
}
