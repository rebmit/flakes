{ pkgs, ... }: {
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock;
    settings = {
      color = "000000";
    };
  };
}
