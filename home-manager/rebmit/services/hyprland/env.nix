{ ... }: {
  wayland.windowManager.hyprland.settings = {
    env = [
      "QT_IM_MODULE, fcitx5"
    ];
  };
}
