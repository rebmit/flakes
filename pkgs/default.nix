{mylib}: rec {
  packages = pkgs: mylib.mapItemNames ./. ["default.nix" "_sources"] (name: pkgs.${name});
  overlay = final: prev: let
    sources = final.callPackage ./_sources/generated.nix {};
  in {
    smartdns-china-list = final.callPackage (import ./smartdns-china-list) {
      dnsmasq-china-list = sources.dnsmasq-china-list;
    };

    systemd-run-app = final.callPackage (import ./systemd-run-app) {};

    telegram-desktop-megumifox = final.callPackage (import ./telegram-desktop-megumifox) {
      archlinuxcn = sources.archlinuxcn;
    };
  };
}
