{ pkgs, ... }: {
  programs.nheko = {
    enable = true;
    package = pkgs.nheko;
  };
}
