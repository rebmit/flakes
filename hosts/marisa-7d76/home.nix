{ pkgs, self, config, ... }: {
  imports = [ self.homeManagerModules.default ];

  home.packages = with pkgs; [
    nheko
    evince
    foliate
    gnome.eog
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

    misc.ssh-desktop = {
      enable = true;
      terminal = "kitty";
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
      thunderbird.enable = true;
      yazi = {
        enable = true;
        enableFishIntegration = true;
      };
      neovim.enable = true;
    };

    services.desktopEnvironment.sway = {
      enable = true;
      browser = {
        startupCommand = "firefox";
        windowCriteria = { app_id = "firefox"; };
      };
      terminal = {
        startupCommand = "kitty";
        windowCriteria = { app_id = "kitty"; };
        launchPrefix = "kitty -e";
      };
      config.output.HDMI-A-1 = { scale = "1.67"; };
    };
  };

  home.persistence."/persist/home/${config.home.username}" = {
    directories = [
      ".config/fcitx5"
      ".config/nheko"
    ];
  };
}
