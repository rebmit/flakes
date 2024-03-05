{
  inputs,
  mylib,
  ...
}: {
  imports = [inputs.nix-colors.homeManagerModules.default] ++ (mylib.getItemPaths ./. "default.nix");

  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-latte;
}
