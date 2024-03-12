{...}: {
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      "float, class: ^(nheko)$"
      "size 75% 75%, class: ^(nheko)$"
      "center, class: ^(nheko)$"
      "workspace special:nheko, class: ^(nheko)$"
    ];

    workspace = [
      "special:nheko, on-created-empty:systemd-run-app nheko"
    ];
  };
}
