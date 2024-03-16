{lib, ...}: {
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "eDP-1, preferred, auto, 1.2"
      "HEADLESS-2, preferred, auto, 1"
      "HDMI-A-1, preferred, auto, 1, mirror, HEADLESS-2"
    ];

    workspace = [
      "9, monitor:HEADLESS-2, default:true"
    ];
  };

  wayland.windowManager.hyprland.extraConfig = lib.mkBefore ''
    exec-once = hyprctl output create headless
  '';
}
