{mylib}: rec {
  packages = pkgs: mylib.mapItemNames ./. "default.nix" (name: pkgs.${name});
  overlay = final: prev:
    mylib.mapItemNames ./. "default.nix" (
      name: let
        package = import ./${name};
      in
        final.callPackage package {}
    );
}
