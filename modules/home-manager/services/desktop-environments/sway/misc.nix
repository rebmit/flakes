{ config, ... }:
let
  activeColors = rec {
    background = "#${config.colorScheme.palette.base00}";
    text = "#${config.colorScheme.palette.base05}";
    childBorder = "#${config.colorScheme.palette.base07}";
    indicator = childBorder;
    border = childBorder;
  };
  inactiveColors = rec {
    background = "#${config.colorScheme.palette.base00}";
    text = "#${config.colorScheme.palette.base05}";
    childBorder = "#${config.colorScheme.palette.base02}";
    indicator = childBorder;
    border = childBorder;
  };
  urgentColors = rec {
    background = "#${config.colorScheme.palette.base00}";
    text = "#${config.colorScheme.palette.base05}";
    childBorder = "#${config.colorScheme.palette.base0A}";
    indicator = childBorder;
    border = childBorder;
  };
in
{
  wayland.windowManager.sway.config = {
    gaps = {
      inner = 5;
      outer = 5;
      smartGaps = false;
      smartBorders = "off";
    };

    window = {
      titlebar = false;
      border = 3;
    };

    floating = {
      titlebar = false;
      border = 3;
    };

    colors = {
      focused = {
        inherit (activeColors) background text childBorder indicator border;
      };
      focusedInactive = {
        inherit (inactiveColors) background text childBorder indicator border;
      };
      unfocused = {
        inherit (inactiveColors) background text childBorder indicator border;
      };
      placeholder = {
        inherit (urgentColors) background text childBorder indicator border;
      };
      urgent = {
        inherit (urgentColors) background text childBorder indicator border;
      };
    };

    bars = [ ];
  };
}
