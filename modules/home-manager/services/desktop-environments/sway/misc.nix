{ ... }: {
  wayland.windowManager.sway.config = {
    gaps = {
      inner = 5;
      outer = 5;
      smartGaps = true;
      smartBorders = "on";
    };

    window = {
      titlebar = false;
    };

    floating = {
      titlebar = false;
    };

    bars = [ ];
  };
}
