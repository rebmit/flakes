{pkgs, ...}: {
  wayland.windowManager.hyprland.extraConfig = ''
    submap = scratchpad

    # window management
    bind = SUPER, Q, togglesplit
    bind = SUPER, A, togglefloating
    bind = SUPER, F, fullscreen
    bind = SUPER SHIFT, Q, killactive
    bind = SUPER SHIFT, F, fakefullscreen

    # fuzzel
    bind = SUPER, V, exec, fuzzel-cliphist

    # play status control
    bindl = , XF86AudioPlay, exec, playerctl play-pause
    bindl = , XF86AudioPrev, exec, playerctl previous
    bindl = , XF86AudioNext, exec, playerctl next
    bindl = SUPER, P, exec, playerctl play-pause
    bindl = SUPER, BracketLeft, exec, playerctl previous
    bindl = SUPER, BracketRight, exec, playerctl next

    # volume control
    bindl = , XF86AudioMute, exec, pulsemixer --toggle-mute
    bindl = , XF86AudioLowerVolume, exec, pulsemixer --change-volume -5
    bindl = , XF86AudioRaiseVolume, exec, pulsemixer --change-volume +5
    bindl = SUPER SHIFT, P, exec, pulsemixer --toggle-mute
    bindl = SUPER SHIFT, BracketLeft, exec, pulsemixer --change-volume -5
    bindl = SUPER SHIFT, BracketLeft, exec, pulsemixer --change-volume +5

    # move and resize window
    bindm = SUPER, mouse:272, movewindow
    bindm = SUPER, mouse:273, resizewindow

    # move focus
    bind = SUPER, H, movefocus, l
    bind = SUPER, J, movefocus, d
    bind = SUPER, K, movefocus, u
    bind = SUPER, L, movefocus, r

    # move window
    bind = SUPER SHIFT, H, movewindow, l
    bind = SUPER SHIFT, J, movewindow, d
    bind = SUPER SHIFT, K, movewindow, u
    bind = SUPER SHIFT, L, movewindow, r

    # submap settings
    bind = SUPER, S, togglespecialworkspace
    bind = SUPER, S, togglespecialworkspace
    bind = SUPER, S, submap, reset

    # scratchpads
    bind = SUPER, 1, togglespecialworkspace, nheko
    bind = SUPER, 2, togglespecialworkspace, telegram
    bind = SUPER, 3, togglespecialworkspace, thunderbird

    submap = reset
  '';
}
