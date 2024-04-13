{ mylib, inputs, ... }: {
  imports = [
    inputs.disko.nixosModules.disko
  ] ++ (mylib.getItemPaths ./. "default.nix");
}
