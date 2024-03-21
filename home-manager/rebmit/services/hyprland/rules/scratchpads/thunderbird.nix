{ ... }: {
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      "workspace special:thunderbird, class: ^(thunderbird)$"
    ];

    workspace = [
      "special:thunderbird, gapsin:5, gapsout:75, on-created-empty:systemd-run-app thunderbird"
    ];
  };
}
