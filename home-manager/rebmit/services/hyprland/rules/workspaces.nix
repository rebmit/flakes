{...}: {
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      "workspace 1, class: ^(kitty)$"
      "workspace 2, class: ^(firefox)$"
    ];
  };
}
