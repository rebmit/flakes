{ pkgs, ... }: {
  home.packages = with pkgs; [ telegram-desktop-megumifox ];

  # fix auto-night mode
  xdg.desktopEntries."org.telegram.desktop" = {
    name = "Telegram Desktop";
    icon = "telegram";
    exec = "env QT_QPA_PLATFORMTHEME=gtk3 telegram-desktop -- %u";
  };
}
