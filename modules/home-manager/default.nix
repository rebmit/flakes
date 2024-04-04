{
  default = { mylib, lib, ... }: {
    imports = mylib.getItemPaths ./. "default.nix";

    custom.baseline.enable = lib.mkDefault true;

    home.username = lib.mkDefault "rebmit";
    home.homeDirectory = lib.mkDefault "/home/rebmit";

    home.stateVersion = "23.11";
  };
}
