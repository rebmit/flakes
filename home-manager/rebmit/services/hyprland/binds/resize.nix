{...}: {
  wayland.windowManager.hyprland.extraConfig = ''
    submap = resize

    # hyprland
    bind = , ESCAPE, submap, reset
    bind = SUPER, R, submap, reset

    # resize active window
    binde = , H, resizeactive, -10 0
    binde = , L, resizeactive, 10 0
    binde = , K, resizeactive, 0 -10
    binde = , J, resizeactive, 0 10
    binde = SHIFT, H, resizeactive, -50 0
    binde = SHIFT, L, resizeactive, 50 0
    binde = SHIFT, K, resizeactive, 0 -50
    binde = SHIFT, J, resizeactive, 0 50

    submap = reset
  '';
}
