{ pkgs, mylib, ... }: {
  imports = mylib.getItemPaths ./. "default.nix";

  home.packages = with pkgs; [
    systemd-run-app
    pavucontrol
    mpv
    htop
    swww
    pulsemixer
    playerctl

    evince
    foliate
    gnome.eog
    thunderbird
  ];

  home.username = "rebmit";
  home.homeDirectory = "/home/rebmit";

  home.stateVersion = "23.11";
}
