{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.nix-colors.homeManagerModules.default];

  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-frappe;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  home.packages = with pkgs; [
    (writeShellApplication {
      name = "toggle-theme";
      runtimeInputs = with pkgs; [home-manager coreutils ripgrep];
      text = ''
        "$(home-manager generations | head -1 | rg -o '/[^ ]*')"/specialisation/light-theme/activate
      '';
    })
  ];

  specialisation.light-theme.configuration = {
    colorScheme = lib.mkForce inputs.nix-colors.colorSchemes.catppuccin-latte;

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = lib.mkForce "prefer-light";
      };
    };

    home.packages = with pkgs; [
      (hiPrio (writeShellApplication {
        name = "toggle-theme";
        runtimeInputs = with pkgs; [home-manager coreutils ripgrep];
        text = ''
          "$(home-manager generations | head -2 | tail -1 | rg -o '/[^ ]*')"/activate
        '';
      }))
    ];
  };
}
