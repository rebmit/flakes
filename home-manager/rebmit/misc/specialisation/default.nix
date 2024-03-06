{
  inputs,
  mylib,
  ...
}: {
  imports = [inputs.nix-colors.homeManagerModules.default] ++ (mylib.getItemPaths ./. "default.nix");

  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-latte;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-light";
    };
  };
}
