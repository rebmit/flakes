{ ... }: {
  packages = pkgs: {
    inherit (pkgs) bird
      bird-babel-rtt
      chnroutes2
      metacubexd
      smartdns-china-list
      systemd-run-app;
  };
  overlay = final: prev:
    let
      sources = final.callPackage ./_sources/generated.nix { };
    in
    rec {
      # packages
      bird-babel-rtt = final.callPackage (import ./bird-babel-rtt) {
        source = sources.bird-babel-rtt;
      };

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

      # aliases
      bird = bird-babel-rtt;
    };
}
