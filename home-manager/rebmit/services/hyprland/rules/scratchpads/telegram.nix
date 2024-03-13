{...}: {
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      "workspace special:telegram, class: ^(org.telegram.desktop|telegramdesktop)$"
    ];

    workspace = [
      "special:telegram, gapsin:5, gapsout:75, on-created-empty:systemd-run-app env QT_QPA_PLATFORMTHEME=gtk3 telegram-desktop"
    ];
  };
}
