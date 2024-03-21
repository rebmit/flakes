{ mylib }: rec {
  packages = pkgs: mylib.mapItemNames ./. [ "default.nix" "_sources" ] (name: pkgs.${name});
  overlay = final: prev:
    let
      sources = final.callPackage ./_sources/generated.nix { };
    in
    {
      fuzzel-cliphist = final.callPackage (import ./fuzzel-cliphist) { };

      hyprland-scratchpad-helper = final.callPackage (import ./hyprland-scratchpad-helper) { };
      hyprland-screenshot-helper = final.callPackage (import ./hyprland-screenshot-helper) { };

      smartdns-china-list = final.callPackage (import ./smartdns-china-list) {
        source = sources.dnsmasq-china-list;
      };

      systemd-run-app = final.callPackage (import ./systemd-run-app) { };

      telegram-desktop-megumifox = final.callPackage (import ./telegram-desktop-megumifox) {
        source = sources.telegram-desktop-megumifox;
      };
    };
}
