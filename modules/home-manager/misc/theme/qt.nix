{ pkgs, config, ... }:
let
  cfg = config.custom.misc.theme;
in
{
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
          "light" = "${cfg.iconThemeLight.name}";
          "dark" = "${cfg.iconThemeDark.name}";
        }
        .${cfg.variant}}
      style=${{
          "light" = "kvantum";
          "dark" = "kvantum-dark";
        }
        .${cfg.variant}}
    '';
  };

  xdg.configFile."qt6ct/qt6ct.conf" = {
    text = ''
      [Appearance]
      icon_theme=${{
          "light" = "${cfg.iconThemeLight.name}";
          "dark" = "${cfg.iconThemeDark.name}";
        }
        .${cfg.variant}}
      style=${{
          "light" = "kvantum";
          "dark" = "kvantum-dark";
        }
        .${cfg.variant}}
    '';
  };

  xdg.configFile."Kvantum" = {
    source = cfg.kvantumSource;
    recursive = true;
  };
}
