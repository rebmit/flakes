{ mylib, ... }: {
  imports = mylib.getItemPaths ./. "default.nix";
}
