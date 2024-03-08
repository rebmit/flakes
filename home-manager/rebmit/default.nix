{
  config,
  lib,
  pkgs,
  inputs,
  mylib,
  ...
}: {
  imports = mylib.getItemPaths ./. "default.nix";

  home.packages = with pkgs; [
    systemd-run-app
    pavucontrol
    mpv
    htop
    swww
    evince
    gnome.eog
  ];

  home.username = "rebmit";
  home.homeDirectory = "/home/rebmit";

  home.stateVersion = "23.11";
}
