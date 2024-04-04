{ pkgs, mylib, ... }: {
  imports = mylib.getItemPaths ./. "default.nix";

  home.stateVersion = "23.11";
}
