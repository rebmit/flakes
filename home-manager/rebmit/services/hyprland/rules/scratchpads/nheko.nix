{ ... }: {
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      "workspace special:nheko, class: ^(nheko)$"
    ];

    workspace = [
      "special:nheko, gapsin:5, gapsout:75, on-created-empty:systemd-run-app nheko"
    ];
  };
}
