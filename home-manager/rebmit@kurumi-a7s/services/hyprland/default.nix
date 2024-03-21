{ ... }: {
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "eDP-1, preferred, auto, 1.2"
      #"HDMI-A-1, preferred, auto, 1, mirror, eDP-1"
      "HDMI-A-1, 1920x1080, auto, 1"
    ];
  };
}
