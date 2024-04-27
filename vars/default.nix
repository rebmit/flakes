{ mylib, lib }: {
  username = "rebmit";
  networks = import ./networks.nix { inherit lib mylib; };
}
