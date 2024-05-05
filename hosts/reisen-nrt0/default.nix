{ self, mylib, mysecrets, ... }: {
  imports =
    [
      self.nixosModules.default
      mysecrets.nixosModules.secrets.reisen-nrt0
      mysecrets.nixosModules.networks.reisen-nrt0
    ]
    ++ (mylib.getItemPaths ./. "default.nix");

  custom = {
    cloud.linode.enable = true;
    networking.overlay.enable = true;
  };

  networking.hostName = "reisen-nrt0";

  system.stateVersion = "23.11";
}