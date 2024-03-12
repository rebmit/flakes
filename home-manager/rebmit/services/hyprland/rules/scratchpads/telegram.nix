{...}: {
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      "float, class: ^(org.telegram.desktop|telegramdesktop)$"
      "size 75% 75%, class: ^(org.telegram.desktop|telegramdesktop)$"
      "center, class: ^(org.telegram.desktop|telegramdesktop)$"
      "workspace special:telegram, class: ^(org.telegram.desktop|telegramdesktop)$"
    ];

    workspace = [
      "special:telegram, on-created-empty:systemd-run-app env QT_QPA_PLATFORMTHEME=gtk3 telegram-desktop"
    ];
  };
}
