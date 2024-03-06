{
  lib,
  inputs,
  ...
}: {
  specialisation.light-theme.configuration = {
    colorScheme = lib.mkForce inputs.nix-colors.colorSchemes.catppuccin-latte;

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = lib.mkForce "prefer-light";
      };
    };
  };
}
