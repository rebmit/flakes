{ pkgs, self, ... }: {
  imports = [ self.homeManagerModules.default ];

  home.packages = with pkgs; [
    nheko
    evince
    foliate
    gnome.eog
    thunderbird
    mpv
    pavucontrol
    systemd-run-app
  ];

  custom = {
    i18n.fcitx5 = {
      enable = true;
      kittySupport = true;
      waylandFrontend = false;
      plasma6Support = true;
      withConfigtool = false;
      addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
      ];
    };

    programs = {
      firefox.enable = true;
      telegram.enable = true;
      fish.enable = true;
      kitty = {
        enable = true;
        shell = "${pkgs.tmux}/bin/tmux new-session -t main";
      };
      tmux = {
        enable = true;
      };
      yazi = {
        enable = true;
        enableFishIntegration = true;
      };
      neovim.enable = true;
    };

    services.desktopEnvironment.hyprland = {
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
  };
}