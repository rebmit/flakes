{ pkgs, config, ... }:
let
  cfg = config.custom.services.desktopEnvironment.sway;
  screenshotHelper = pkgs.writeShellApplication {
    name = "sway-screenshot-helper";
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
  modifier = config.wayland.windowManager.sway.config.modifier;
in
{
  wayland.windowManager.sway.config.modes = {
    resize = {
      Escape = "mode default";
      Return = "mode default";
      "${modifier}+r" = "mode default";
      h = "resize shrink width 10 px";
      j = "resize grow height 10 px";
      k = "resize shrink height 10 px";
      l = "resize grow width 10 px";
    };
    scratchpad = {
      Escape = "mode default";
      Return = "mode default";
      "${modifier}+s" = "mode default";
    };
  };

  wayland.windowManager.sway.config.keybindings = {
    "${modifier}+r" = "mode resize";
    "${modifier}+s" = "mode scratchpad";
    "${modifier}+Shift+q" = "kill";
    "${modifier}+q" = "split toggle";
    "${modifier}+f" = "fullscreen toggle";
    "${modifier}+a" = "floating toggle";
    "${modifier}+h" = "focus left";
    "${modifier}+j" = "focus down";
    "${modifier}+k" = "focus up";
    "${modifier}+l" = "focus right";
    "${modifier}+Shift+h" = "move left";
    "${modifier}+Shift+j" = "move down";
    "${modifier}+Shift+k" = "move up";
    "${modifier}+Shift+l" = "move right";
    "${modifier}+d" = "exec fuzzel";
    "${modifier}+v" = "exec ${cliphistHelper}/bin/fuzzel-cliphist";
    "${modifier}+Shift+s" = "exec ${screenshotHelper}/bin/sway-screenshot-helper";
    "${modifier}+Return" = "exec systemd-run-app ${cfg.terminal.startupCommand}";
    "${modifier}+w" = "exec systemd-run-app ${cfg.browser.startupCommand}";
    "${modifier}+m" = "exec swaylock";
    "${modifier}+Tab" = "workspace next";
    "${modifier}+Shift+Tab" = "workspace prev";
    "${modifier}+1" = "workspace 1";
    "${modifier}+2" = "workspace 2";
    "${modifier}+3" = "workspace 3";
    "${modifier}+4" = "workspace 4";
    "${modifier}+5" = "workspace 5";
    "${modifier}+6" = "workspace 6";
    "${modifier}+7" = "workspace 7";
    "${modifier}+8" = "workspace 8";
    "${modifier}+9" = "workspace 9";
    "${modifier}+Shift+1" = "move container to workspace 1; workspace 1";
    "${modifier}+Shift+2" = "move container to workspace 2; workspace 2";
    "${modifier}+Shift+3" = "move container to workspace 3; workspace 3";
    "${modifier}+Shift+4" = "move container to workspace 4; workspace 4";
    "${modifier}+Shift+5" = "move container to workspace 5; workspace 5";
    "${modifier}+Shift+6" = "move container to workspace 6; workspace 6";
    "${modifier}+Shift+7" = "move container to workspace 7; workspace 7";
    "${modifier}+Shift+8" = "move container to workspace 8; workspace 8";
    "${modifier}+Shift+9" = "move container to workspace 9; workspace 9";
    "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
    "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
    "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
    "${modifier}+p" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
    "${modifier}+BracketLeft" = "exec ${pkgs.playerctl}/bin/playerctl previous";
    "${modifier}+BracketRight" = "exec ${pkgs.playerctl}/bin/playerctl next";
    "XF86AudioMute" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --toggle-mute";
    "XF86AudioLowerVolume" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --change-volume -5";
    "XF86AudioRaiseVolume" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --change-volume +5";
    "${modifier}+Shift+p" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --toggle-mute";
    "${modifier}+Shift+BracketLeft" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --change-volume -5";
    "${modifier}+Shift+BracketRight" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --change-volume +5";
  };
}
