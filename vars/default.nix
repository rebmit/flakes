{ mylib, lib }: {
  networks = import ./networks.nix { inherit lib mylib; };
}
