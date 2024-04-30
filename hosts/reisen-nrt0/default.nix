{ self, mylib, ... }: {
  imports =
    [
      self.nixosModules.default
    ]
    ++ (mylib.getItemPaths ./. "default.nix");

  custom.cloud.linode.enable = true;

  networking.hostName = "reisen-nrt0";

  system.stateVersion = "23.11";
}
