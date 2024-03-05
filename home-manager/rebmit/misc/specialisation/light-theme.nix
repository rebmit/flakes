{
  lib,
  inputs,
  ...
}: {
  specialisation.light-theme.configuration = {
    colorScheme = lib.mkForce inputs.nix-colors.colorSchemes.catppuccin-latte;
  };
}
