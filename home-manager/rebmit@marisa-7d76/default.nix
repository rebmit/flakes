{ self, ... }: {
  imports = [
    ../rebmit
    self.homeManagerModules.default
  ];

  custom.services.desktopEnvironment.hyprland = {
    enable = true;
    browser = {
      startupCommand = "firefox";
      windowRegex = "class: ^(firefox)$";
    };
    terminal = {
      startupCommand = "kitty";
      windowRegex = "class: ^(kitty)$";
      launchPrefix = "kitty -e";
    };
    settings = {
      monitor = [
        "HDMI-A-1, preferred, auto, 1.67"
      ];
    };
    scratchpads = {
      nheko = {
        startupCommand = "nheko";
        windowRegex = "class: ^(nheko)$";
        keyBind = "SUPER, 1";
      };
      telegram = {
        startupCommand = "env QT_QPA_PLATFORMTHEME=gtk3 telegram-desktop";
        windowRegex = "class: ^(org.telegram.desktop|telegramdesktop)$";
        keyBind = "SUPER, 2";
      };
      thunderbird = {
        startupCommand = "thunderbird";
        windowRegex = "class: ^(thunderbird)$";
        keyBind = "SUPER, 3";
      };
    };
  };
}
