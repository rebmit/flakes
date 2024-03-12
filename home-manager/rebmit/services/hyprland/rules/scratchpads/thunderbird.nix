{...}: {
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      "float, class: ^(thunderbird)$"
      "size 75% 75%, class: ^(thunderbird)$"
      "center, class: ^(thunderbird)$"
      "workspace special:thunderbird, class: ^(thunderbird)$"
    ];

    workspace = [
      "special:thunderbird, on-created-empty:systemd-run-app thunderbird"
    ];
  };
}
