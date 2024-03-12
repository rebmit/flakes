{...}: {
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      "float, class: ^(eog)$"
      "size 75% 75%, class: ^(eog)$"
      "center, class: ^(eog)$"
    ];
  };
}
