{ config, pkgs, ... }: {
  qt = {
    enable = true;
    platformTheme = "qtct";
  };

  home.packages = with pkgs; [
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum
  ];

  xdg.configFile."qt5ct/qt5ct.conf" = {
    text = ''
      [Appearance]
      icon_theme=${{
          "catppuccin-latte" = "Papirus-Light";
          "catppuccin-frappe" = "Papirus-Dark";
        }
        .${config.colorScheme.slug}}
      style=${{
          "catppuccin-latte" = "kvantum";
          "catppuccin-frappe" = "kvantum-dark";
        }
        .${config.colorScheme.slug}}
    '';
  };

  xdg.configFile."qt6ct/qt6ct.conf" = {
    text = ''
      [Appearance]
      icon_theme=${{
          "catppuccin-latte" = "Papirus-Light";
          "catppuccin-frappe" = "Papirus-Dark";
        }
        .${config.colorScheme.slug}}
      style=${{
          "catppuccin-latte" = "kvantum";
          "catppuccin-frappe" = "kvantum-dark";
        }
        .${config.colorScheme.slug}}
    '';
  };

  xdg.configFile."Kvantum" = {
    source = ./kvantum;
    recursive = true;
  };
}
