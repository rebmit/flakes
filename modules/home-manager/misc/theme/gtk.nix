{ config, ... }:
let
  cfg = config.custom.misc.theme;
in
{
  gtk = {
    enable = true;
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    cursorTheme = {
      "light" = cfg.cursorThemeLight;
      "dark" = cfg.cursorThemeDark;
    }.${cfg.variant};
    iconTheme = {
      "light" = cfg.iconThemeLight;
      "dark" = cfg.iconThemeDark;
    }.${cfg.variant};
    theme = {
      "light" = cfg.gtkThemeLight;
      "dark" = cfg.gtkThemeDark;
    }.${cfg.variant};
  };

  home.pointerCursor = {
    "light" = cfg.cursorThemeLight;
    "dark" = cfg.cursorThemeDark;
  }.${cfg.variant};

  wayland.windowManager.sway.config.seat."*" = {
    xcursor_theme = "${config.home.pointerCursor.name} ${toString config.home.pointerCursor.size}";
  };
}
