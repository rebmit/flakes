{ ... }: {
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      "float, class: ^(pavucontrol)$"
      "size 50% 50%, class: ^(pavucontrol)$"
      "center, class: ^(pavucontrol)$"
    ];
  };
}
