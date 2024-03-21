{ writeShellApplication, cliphist, fuzzel, wl-clipboard }:
writeShellApplication {
  name = "fuzzel-cliphist";
  text = ''
    ${cliphist}/bin/cliphist list | ${fuzzel}/bin/fuzzel -d | ${cliphist}/bin/cliphist decode | ${wl-clipboard}/bin/wl-copy
  '';
}
