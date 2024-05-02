{ config, ... }: {
  programs.waybar.style = ''
    * {
      border: none;
      border-radius: 0;
      font-family: 'RobotoMono Nerd Font', 'sans';
      font-size: 11pt;
      font-weight: bold;
      min-height: 0;
      color: #${config.colorScheme.palette.base05};
    }

    window#waybar {
      padding: 0pt;
      opacity: 0.95;
      color: #${config.colorScheme.palette.base05};
      background: #${config.colorScheme.palette.base00};
      border-bottom: 2pt solid #${config.colorScheme.palette.base02};
    }

    window#waybar.hidden {
      opacity: 0.0;
    }

    #workspaces button {
      padding: 0pt;
      background: transparent;
      color: #${config.colorScheme.palette.base05};
      border-bottom: 2pt solid transparent;
    }

    #workspaces button.focused,
    #workspaces button.active {
      background: #${config.colorScheme.palette.base02};
      border-bottom: 2pt solid #${config.colorScheme.palette.base07};
    }

    #workspaces button.urgent {
      background: #${config.colorScheme.palette.base0A};
    }

    #custom-nixos {
      padding-left: 12pt;
      padding-right: 15pt;
    }

    #mode,
    #window {
      padding: 0pt 8pt;
    }

    #idle_inhibitor,
    #tray,
    #pulseaudio,
    #network,
    #backlight,
    #temperature,
    #memory,
    #cpu,
    #battery,
    #clock {
      margin: 0pt 0pt;
      padding: 0pt 8pt;
    }

    #idle_inhibitor,
    #tray,
    #pulseaudio,
    #network,
    #backlight,
    #temperature,
    #memory,
    #cpu,
    #battery,
    #clock {
      border-left: 2pt solid #${config.colorScheme.palette.base02};
    }
  '';
}
