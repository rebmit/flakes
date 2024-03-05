{
  lib,
  inputs,
  ...
}: {
  specialisation.dark-theme.configuration = {
    colorScheme = lib.mkForce inputs.nix-colors.colorSchemes.catppuccin-frappe;
  };
}
