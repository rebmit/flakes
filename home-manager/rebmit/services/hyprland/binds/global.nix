{pkgs, ...}: {
  wayland.windowManager.hyprland.settings = {
    bindm = [
      # move and resize window
      "SUPER, mouse:272, movewindow"
      "SUPER, mouse:273, resizewindow"
    ];

    bindl = [
      # play status control
      ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
      ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
      ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
      "SUPER, P, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
      "SUPER, BracketLeft, exec, ${pkgs.playerctl}/bin/playerctl previous"
      "SUPER, BracketRight, exec, ${pkgs.playerctl}/bin/playerctl next"
      # volume control
      ", XF86AudioMute, exec, ${pkgs.pulsemixer}/bin/pulsemixer --toggle-mute"
      ", XF86AudioLowerVolume, exec, ${pkgs.pulsemixer}/bin/pulsemixer --change-volume -5"
      ", XF86AudioRaiseVolume, exec, ${pkgs.pulsemixer}/bin/pulsemixer --change-volume +5"
      "SUPER SHIFT, P, exec, ${pkgs.pulsemixer}/bin/pulsemixer --toggle-mute"
      "SUPER SHIFT, BracketLeft, exec, ${pkgs.pulsemixer}/bin/pulsemixer --change-volume -5"
      "SUPER SHIFT, BracketLeft, exec, ${pkgs.pulsemixer}/bin/pulsemixer --change-volume +5"
    ];

    bind = [
      # hyprland settings
      "SUPER ALT, Q, exit"
      # hyprland submap
      "SUPER, R, submap, resize"
      "SUPER, C, submap, config"
      "SUPER, S, submap, scratchpad"
      # window management
      "SUPER, Q, togglesplit"
      "SUPER, A, togglefloating"
      "SUPER, F, fullscreen"
      "SUPER SHIFT, Q, killactive"
      "SUPER SHIFT, F, fakefullscreen"
      # apps launcher
      "SUPER, RETURN, exec, systemd-run-app ${pkgs.kitty}/bin/kitty"
      "SUPER, W, exec, systemd-run-app firefox"
      "SUPER, D, exec, ${pkgs.fuzzel}/bin/fuzzel"
      # fuzzel utils
      "SUPER, V, exec, ${pkgs.cliphist}/bin/cliphist list | ${pkgs.fuzzel}/bin/fuzzel -d | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy"
      # move focus
      "SUPER, H, movefocus, l"
      "SUPER, J, movefocus, d"
      "SUPER, K, movefocus, u"
      "SUPER, L, movefocus, r"
      # move window
      "SUPER SHIFT, H, movewindow, l"
      "SUPER SHIFT, J, movewindow, d"
      "SUPER SHIFT, K, movewindow, u"
      "SUPER SHIFT, L, movewindow, r"
      # switch workspaces
      "SUPER, TAB, exec, hyprctl dispatch workspace e+1"
      "SUPER SHIFT, TAB, exec, hyprctl dispatch workspace e-1"
      "SUPER, 1, workspace, 1"
      "SUPER, 2, workspace, 2"
      "SUPER, 3, workspace, 3"
      "SUPER, 4, workspace, 4"
      "SUPER, 5, workspace, 5"
      "SUPER, 6, workspace, 6"
      "SUPER, 7, workspace, 7"
      "SUPER, 8, workspace, 8"
      "SUPER, 9, workspace, 9"
      # move active window to a workspace
      "SUPER SHIFT, 1, movetoworkspace, 1"
      "SUPER SHIFT, 2, movetoworkspace, 2"
      "SUPER SHIFT, 3, movetoworkspace, 3"
      "SUPER SHIFT, 4, movetoworkspace, 4"
      "SUPER SHIFT, 5, movetoworkspace, 5"
      "SUPER SHIFT, 6, movetoworkspace, 6"
      "SUPER SHIFT, 7, movetoworkspace, 7"
      "SUPER SHIFT, 8, movetoworkspace, 8"
      "SUPER SHIFT, 9, movetoworkspace, 9"
    ];
  };
}
