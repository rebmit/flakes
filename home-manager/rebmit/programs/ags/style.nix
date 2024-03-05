{config, ...}: {
  xdg.configFile."ags/style.css" = {
    text = ''
      * {
        border: none;
        border-radius: 0;
        font-family: 'system-ui';
        font-size: 11pt;
        color: #${config.colorScheme.palette.base05};
      }

      button {
        background: #${config.colorScheme.palette.base00};
        min-height: 18pt;
      }

      .bar, .battery, .cpu, .clock, .darkman, .hyprland-submap, .memory, .mpris, .network, .pulseaudio, .systray {
        opacity: 0.95;
        background: #${config.colorScheme.palette.base00};
        border-bottom: 2pt solid #${config.colorScheme.palette.base02};
      }

      .hyprland-workspaces button {
        padding: 0pt 5pt;
        background: transparent;
        color: #FFFFFF;
        border-bottom: 2pt solid transparent;
      }

      .hyprland-workspaces button.focused {
        background: #${config.colorScheme.palette.base02};
        border-bottom: 2pt solid #FFFFFF;
      }

      .hyprland-submap {
        padding: 0pt 7.5pt;
      }

      .spacer {
        background: #${config.colorScheme.palette.base02};
        min-width: 2pt;
      }
    '';
  };
}
