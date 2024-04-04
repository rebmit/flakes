{ inputs, pkgs, config, lib, mylib, ... } @ args:
with lib; let
  cfg = config.custom.misc.theme;
  themeOpts = { ... }: {
    options = {
      package = mkOption {
        type = types.nullOr types.package;
        default = null;
      };
      name = mkOption {
        type = types.str;
      };
    };
  };
  iconOpts = { ... }: {
    options = {
      package = mkOption {
        type = types.nullOr types.package;
        default = null;
      };
      name = mkOption {
        type = types.str;
      };
    };
  };
  cursorOpts = { ... }: {
    options = {
      package = mkOption {
        type = types.nullOr types.package;
        default = null;
      };
      name = mkOption {
        type = types.str;
      };
      size = mkOption {
        type = types.nullOr types.int;
        default = 36;
      };
    };
  };
in
{
  imports = [ inputs.nix-colors.homeManagerModules.default ];

  options.custom.misc.theme = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
    colorSchemeLight = mkOption {
      default = inputs.nix-colors.colorSchemes.catppuccin-latte;
    };
    colorSchemeDark = mkOption {
      default = inputs.nix-colors.colorSchemes.catppuccin-frappe;
    };
    gtkThemeLight = mkOption {
      type = types.submodule themeOpts;
      default = {
        name = "Catppuccin-Latte-Compact-Blue-Light";
        package = pkgs.catppuccin-gtk.override {
          accents = [ "blue" ];
          size = "compact";
          variant = "latte";
        };
      };
    };
    gtkThemeDark = mkOption {
      type = types.submodule themeOpts;
      default = {
        name = "Catppuccin-Frappe-Compact-Blue-Dark";
        package = pkgs.catppuccin-gtk.override {
          accents = [ "blue" ];
          size = "compact";
          variant = "frappe";
        };
      };
    };
    cursorThemeLight = mkOption {
      type = types.submodule cursorOpts;
      default = {
        name = "capitaine-cursors";
        package = pkgs.capitaine-cursors;
        size = 36;
      };
    };
    cursorThemeDark = mkOption {
      type = types.submodule cursorOpts;
      default = {
        name = "capitaine-cursors";
        package = pkgs.capitaine-cursors;
        size = 36;
      };
    };
    iconThemeLight = mkOption {
      type = types.submodule iconOpts;
      default = {
        name = "Papirus-Light";
        package = pkgs.papirus-icon-theme;
      };
    };
    iconThemeDark = mkOption {
      type = types.submodule iconOpts;
      default = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
    };
    kvantumSource = mkOption {
      type = types.path;
      default = ./kvantum;
    };
    variant = mkOption {
      type = types.enum [ "dark" "light" ];
    };
  };

  config = mkIf cfg.enable (
    mkMerge ([
      {
        colorScheme = cfg.colorSchemeDark;
        dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
        custom.misc.theme.variant = "dark";

        home.packages = with pkgs; [
          (writeShellApplication {
            name = "toggle-theme";
            runtimeInputs = with pkgs; [ home-manager coreutils ripgrep ];
            text = ''
              "$(home-manager generations | head -1 | rg -o '/[^ ]*')"/specialisation/light-theme/activate
            '';
          })
        ];

        specialisation.light-theme.configuration = {
          colorScheme = mkForce cfg.colorSchemeLight;
          dconf.settings."org/gnome/desktop/interface".color-scheme = mkForce "prefer-light";
          custom.misc.theme.variant = mkForce "light";

          home.packages = with pkgs; [
            (hiPrio (writeShellApplication {
              name = "toggle-theme";
              runtimeInputs = with pkgs; [ home-manager coreutils ripgrep ];
              text = ''
                "$(home-manager generations | head -2 | tail -1 | rg -o '/[^ ]*')"/activate
              '';
            }))
          ];
        };
      }
    ] ++ (map (path: import path args) (mylib.getItemPaths ./. "default.nix")))
  );
}
