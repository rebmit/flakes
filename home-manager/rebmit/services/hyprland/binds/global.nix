{pkgs, ...}: {
  wayland.windowManager.hyprland.extraConfig = ''
      # hyprland settings
      bind = SUPER ALT, Q, exit

      # hyprland submap
      bind = SUPER, R, submap, resize
      bind = SUPER, C, submap, config
      bind = SUPER, S, submap, scratchpad

      # window management
      bind = SUPER, Q, togglesplit
      bind = SUPER, A, togglefloating
      bind = SUPER, F, fullscreen
      bind = SUPER SHIFT, Q, killactive
      bind = SUPER SHIFT, F, fakefullscreen

      # app
      bind = SUPER, RETURN, exec, systemd-run-app ${pkgs.kitty}/bin/kitty
      bind = SUPER, W, exec, systemd-run-app ${pkgs.firefox}/bin/firefox

      # fuzzel
      bind = SUPER, D, exec, ${pkgs.fuzzel}/bin/fuzzel
      bind = SUPER, V, exec, ${pkgs.fuzzel-cliphist}/bin/fuzzel-cliphist

      # play status control
      bindl = , XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause
      bindl = , XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous
      bindl = , XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next
      bindl = SUPER, P, exec, ${pkgs.playerctl}/bin/playerctl play-pause
      bindl = SUPER, BracketLeft, exec, ${pkgs.playerctl}/bin/playerctl previous
      bindl = SUPER, BracketRight, exec, ${pkgs.playerctl}/bin/playerctl next

      # volume control
      bindl = , XF86AudioMute, exec, ${pkgs.pulsemixer}/bin/pulsemixer --toggle-mute
      bindl = , XF86AudioLowerVolume, exec, ${pkgs.pulsemixer}/bin/pulsemixer --change-volume -5
      bindl = , XF86AudioRaiseVolume, exec, ${pkgs.pulsemixer}/bin/pulsemixer --change-volume +5
      bindl = SUPER SHIFT, P, exec, ${pkgs.pulsemixer}/bin/pulsemixer --toggle-mute
      bindl = SUPER SHIFT, BracketLeft, exec, ${pkgs.pulsemixer}/bin/pulsemixer --change-volume -5
      bindl = SUPER SHIFT, BracketLeft, exec, ${pkgs.pulsemixer}/bin/pulsemixer --change-volume +5

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

      # switch workspaces
      bind = SUPER, TAB, exec, hyprctl dispatch workspace e+1
      bind = SUPER SHIFT, TAB, exec, hyprctl dispatch workspace e-1
      bind = SUPER, 1, workspace, 1
      bind = SUPER, 2, workspace, 2
      bind = SUPER, 3, workspace, 3
      bind = SUPER, 4, workspace, 4
      bind = SUPER, 5, workspace, 5
      bind = SUPER, 6, workspace, 6
      bind = SUPER, 7, workspace, 7
      bind = SUPER, 8, workspace, 8
      bind = SUPER, 9, workspace, 9

      # move active window to a workspace
      bind = SUPER SHIFT, 1, movetoworkspace, 1
      bind = SUPER SHIFT, 2, movetoworkspace, 2
      bind = SUPER SHIFT, 3, movetoworkspace, 3
      bind = SUPER SHIFT, 4, movetoworkspace, 4
      bind = SUPER SHIFT, 5, movetoworkspace, 5
      bind = SUPER SHIFT, 6, movetoworkspace, 6
      bind = SUPER SHIFT, 7, movetoworkspace, 7
      bind = SUPER SHIFT, 8, movetoworkspace, 8
      bind = SUPER SHIFT, 9, movetoworkspace, 9
  '';
}
