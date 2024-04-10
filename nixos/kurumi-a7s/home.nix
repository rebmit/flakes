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

    misc.ssh-desktop = {
      enable = true;
      terminal = "kitty";
    };

    programs = {
      firefox.enable = true;
      fish = {
        enable = true;
        shellAliases = {
          p = "powerprofilesctl";
        };
      };
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
          "eDP-1, preferred, auto, 1.2"
          #"HDMI-A-1, preferred, auto, 1, mirror, eDP-1"
          "HDMI-A-1, 1920x1080, auto, 1"
        ];
      };
      scratchpads = {
        nheko = {
          startupCommand = "nheko";
          windowRegex = "class: ^(nheko)$";
          keyBind = "SUPER, 1";
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
