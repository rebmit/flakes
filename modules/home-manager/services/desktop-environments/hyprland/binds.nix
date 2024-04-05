{ pkgs, config, lib, ... }:
with lib; let
  cfg = config.custom.services.desktopEnvironment.hyprland;
  screenshotHelper = pkgs.writeShellApplication {
    name = "hyprland-screenshot-helper";
    text = ''
      ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -o -r -c '#ff0000ff')" - | ${pkgs.satty}/bin/satty --filename - --fullscreen --copy-command ${pkgs.wl-clipboard}/bin/wl-copy
    '';
  };
  cliphistHelper = pkgs.writeShellApplication {
    name = "fuzzel-cliphist";
    text = ''
      ${pkgs.cliphist}/bin/cliphist list | ${pkgs.fuzzel}/bin/fuzzel -d | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
    '';
  };
  renderScratchpad = name: cfg: ''
    bind = ${cfg.keyBind}, togglespecialworkspace, ${name}
  '';
  commonBindConfig = ''
    bind = SUPER, Q, togglesplit
    bind = SUPER, A, togglefloating
    bind = SUPER, F, fullscreen
    bind = SUPER SHIFT, Q, killactive
    bind = SUPER SHIFT, F, fakefullscreen
    bindl = , XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause
    bindl = , XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous
    bindl = , XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next
    bindl = SUPER, P, exec, ${pkgs.playerctl}/bin/playerctl play-pause
    bindl = SUPER, BracketLeft, exec, ${pkgs.playerctl}/bin/playerctl previous
    bindl = SUPER, BracketRight, exec, ${pkgs.playerctl}/bin/playerctl next
    bindl = , XF86AudioMute, exec, ${pkgs.pulsemixer}/bin/pulsemixer --toggle-mute
    bindl = , XF86AudioLowerVolume, exec, ${pkgs.pulsemixer}/bin/pulsemixer --change-volume -5
    bindl = , XF86AudioRaiseVolume, exec, ${pkgs.pulsemixer}/bin/pulsemixer --change-volume +5
    bindl = SUPER SHIFT, P, exec, ${pkgs.pulsemixer}/bin/pulsemixer --toggle-mute
    bindl = SUPER SHIFT, BracketLeft, exec, ${pkgs.pulsemixer}/bin/pulsemixer --change-volume -5
    bindl = SUPER SHIFT, BracketLeft, exec, ${pkgs.pulsemixer}/bin/pulsemixer --change-volume +5
    bindm = SUPER, mouse:272, movewindow
    bindm = SUPER, mouse:273, resizewindow
    bind = SUPER, H, movefocus, l
    bind = SUPER, J, movefocus, d
    bind = SUPER, K, movefocus, u
    bind = SUPER, L, movefocus, r
    bind = SUPER SHIFT, H, movewindow, l
    bind = SUPER SHIFT, J, movewindow, d
    bind = SUPER SHIFT, K, movewindow, u
    bind = SUPER SHIFT, L, movewindow, r
    bind = SUPER, D, exec, fuzzel
    bind = SUPER, V, exec, ${cliphistHelper}/bin/fuzzel-cliphist
    bind = SUPER SHIFT, S, exec, ${screenshotHelper}/bin/hyprland-screenshot-helper
  '';
in
{
  wayland.windowManager.hyprland.extraConfig = ''
    bind = SUPER ALT, Q, exit
    bind = SUPER, R, submap, resize
    bind = SUPER, S, submap, scratchpad
    ${commonBindConfig}
    bind = SUPER, RETURN, exec, systemd-run-app ${cfg.terminal.startupCommand}
    bind = SUPER, W, exec, systemd-run-app ${cfg.browser.startupCommand}
    bind = SUPER, M, exec, swaylock
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
    bind = SUPER SHIFT, 1, movetoworkspace, 1
    bind = SUPER SHIFT, 2, movetoworkspace, 2
    bind = SUPER SHIFT, 3, movetoworkspace, 3
    bind = SUPER SHIFT, 4, movetoworkspace, 4
    bind = SUPER SHIFT, 5, movetoworkspace, 5
    bind = SUPER SHIFT, 6, movetoworkspace, 6
    bind = SUPER SHIFT, 7, movetoworkspace, 7
    bind = SUPER SHIFT, 8, movetoworkspace, 8
    bind = SUPER SHIFT, 9, movetoworkspace, 9
    submap = resize
    bind = , ESCAPE, submap, reset
    bind = SUPER, R, submap, reset
    binde = , H, resizeactive, -10 0
    binde = , L, resizeactive, 10 0
    binde = , K, resizeactive, 0 -10
    binde = , J, resizeactive, 0 10
    binde = SHIFT, H, resizeactive, -50 0
    binde = SHIFT, L, resizeactive, 50 0
    binde = SHIFT, K, resizeactive, 0 -50
    binde = SHIFT, J, resizeactive, 0 50
    submap = reset
    submap = scratchpad
    ${commonBindConfig}
    bind = SUPER, S, togglespecialworkspace
    bind = SUPER, S, togglespecialworkspace
    bind = SUPER, S, submap, reset
    ${concatStringsSep "\n" (mapAttrsToList renderScratchpad cfg.scratchpads)}
    submap = reset
  '';
}
