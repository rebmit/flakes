{ mylib, inputs, ... }: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ] ++ (mylib.getItemPaths ./. "default.nix");
}
