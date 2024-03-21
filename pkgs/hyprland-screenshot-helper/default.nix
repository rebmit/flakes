{ writeShellApplication, wl-clipboard, satty, grim, slurp }:
writeShellApplication {
  name = "hyprland-screenshot-helper";
  text = ''
    ${grim}/bin/grim -g "$(${slurp}/bin/slurp -o -r -c '#ff0000ff')" - | ${satty}/bin/satty --filename - --fullscreen --copy-command ${wl-clipboard}/bin/wl-copy
  '';
}
