{
  system,
  self,
  nixpkgs,
  inputs,
  mylib,
}:
nixpkgs.lib.nixosSystem {
  inherit system;

  modules = mylib.getItemPaths ./. "default.nix";

  specialArgs = {
    inherit inputs mylib self;
  };
}
