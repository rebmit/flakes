{
  config,
  pkgs,
  ...
}: {
  gtk = {
    enable = true;
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    cursorTheme = {
      name = "capitaine-cursors";
      package = pkgs.capitaine-cursors;
      size = 36;
    };
    font = {
      name = "system-ui";
      size = 11;
    };
    iconTheme = {
      name =
        {
          "catppuccin-latte" = "Papirus-Light";
          "catppuccin-frappe" = "Papirus-Dark";
        }
        .${config.colorScheme.slug};
      package = pkgs.papirus-icon-theme;
    };
    theme =
      {
        "catppuccin-latte" = {
          name = "Catppuccin-Latte-Compact-Blue-Light";
          package = pkgs.catppuccin-gtk.override {
            accents = ["blue"];
            size = "compact";
            variant = "latte";
          };
        };
        "catppuccin-frappe" = {
          name = "Catppuccin-Frappe-Compact-Blue-Dark";
          package = pkgs.catppuccin-gtk.override {
            accents = ["blue"];
            size = "compact";
            variant = "frappe";
          };
        };
      }
      .${config.colorScheme.slug};
  };
}
