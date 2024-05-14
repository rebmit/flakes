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
      waylandFrontend = false;
      plasma6Support = true;
      withConfigtool = false;
      addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
      ];
    };

    misc.ssh-desktop = {
      enable = true;
      terminal = "foot";
    };

    programs = {
      firefox.enable = true;
      telegram.enable = true;
      fish.enable = true;
      foot = {
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
        startupCommand = "foot";
        windowCriteria = { app_id = "foot"; };
        launchPrefix = "foot";
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
