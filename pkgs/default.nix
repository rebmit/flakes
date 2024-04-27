{ mylib, ... }: {
  packages = pkgs: mylib.mapItemNames ./. [ "default.nix" "_sources" ] (name: pkgs.${name});
  overlay = final: prev:
    let
      sources = final.callPackage ./_sources/generated.nix { };
    in
    {
      chnroutes2 = final.callPackage (import ./chnroutes2) {
        source = sources.chnroutes2;
      };

      metacubexd = final.callPackage (import ./metacubexd) {
        source = sources.metacubexd;
      };

      smartdns-china-list = final.callPackage (import ./smartdns-china-list) {
        source = sources.dnsmasq-china-list;
      };

      systemd-run-app = final.callPackage (import ./systemd-run-app) { };

      telegram-desktop-megumifox = final.callPackage (import ./telegram-desktop-megumifox) {
        source = sources.telegram-desktop-megumifox;
      };
    };
}
