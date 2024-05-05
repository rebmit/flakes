{ mylib, lib, mysecrets }: {
  username = "rebmit";
  networks = import ./networks.nix { inherit lib mylib mysecrets; };
}
