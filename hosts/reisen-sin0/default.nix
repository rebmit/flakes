{ mylib, mysecrets, ... }: {
  imports =
    [
      mysecrets.nixosModules.secrets.reisen-sin0
      mysecrets.nixosModules.networks.reisen-sin0
    ]
    ++ (mylib.getItemPaths ./. "default.nix");

  custom = {
    cloud.linode.enable = true;
    networking.overlay.enable = true;
  };

  networking.hostName = "reisen-sin0";

  system.stateVersion = "23.11";
}
