{
  config,
  pkgs,
  mylib,
  ...
}: {
  imports = mylib.getItemPaths ./. "default.nix";

  home.packages = with pkgs; [
    hyprland-scratchpad-helper
    fuzzel-cliphist
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;

    settings = {
      animations = {
        enabled = "yes";

        bezier = "quart, 0.25, 1, 0.5, 1";

        animation = [
          "windows, 1, 6, quart, slide"
          "border, 1, 6, quart"
          "borderangle, 1, 6, quart"
          "fade, 1, 6, quart"
          "workspaces, 1, 6, quart"
        ];
      };

      decoration = {
        rounding = "0";

        blur = {
          enabled = "true";
          xray = "true";
          size = "10";
          passes = "4";
          new_optimizations = "true";
        };

        drop_shadow = "false";
        shadow_range = "15";
        shadow_render_power = "4";
        "col.shadow" = "rgb(${config.colorScheme.palette.base00})";
      };

      dwindle = {
        pseudotile = "false";
        preserve_split = "true";
      };

      general = {
        gaps_in = "5";
        gaps_out = "10";
        border_size = "3";
        "col.active_border" = "rgb(${config.colorScheme.palette.base05})";
        "col.inactive_border" = "rgb(${config.colorScheme.palette.base00})";
      };

      xwayland = {
        use_nearest_neighbor = "false";
      };

      misc = {
        focus_on_activate = "true";
        disable_hyprland_logo = "true";
        close_special_on_empty = "true";
      };
    };
  };
}
