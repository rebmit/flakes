{...}: {
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      # "suppressevent fullscreen, title:^(Extension: (Bitwarden - Free Password Manager) - Bitwarden — Mozilla Firefox)$"
      "float, title:^(Extension: (Bitwarden - Free Password Manager) - Bitwarden — Mozilla Firefox)$"
    ];
  };
}
