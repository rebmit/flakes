{ self, mylib, ... }: {
  imports =
    [
      self.nixosModules.default
    ]
    ++ (mylib.getItemPaths ./. "default.nix");

  custom = {
    baseline.enable = true;
    cloud.linode.enable = true;
    system.disko.btrfs-bios-common = {
      enable = true;
      device = "/dev/sda";
    };
  };

  networking.hostName = "reisen-sin0";

  system.stateVersion = "23.11";
}
