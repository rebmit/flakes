{
  default = { mylib, ... }: {
    imports = mylib.getItemPaths ./. "default.nix";

    programs.bash.enable = true;

    home.stateVersion = "23.11";
  };
}
