{
  lib,
  inputs,
  ...
}: {
  specialisation.dark-theme.configuration = {
    colorScheme = lib.mkForce inputs.nix-colors.colorSchemes.catppuccin-frappe;

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = lib.mkForce "prefer-dark";
      };
    };
  };
}
