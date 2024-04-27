{
  default = { mylib, lib, impermanence, ags, nix-colors, config, ... }: {
    imports = [
      impermanence.nixosModules.home-manager.impermanence
      ags.homeManagerModules.default
      nix-colors.homeManagerModules.default
    ] ++ (mylib.getItemPaths ./. "default.nix");

    custom.baseline.enable = lib.mkDefault true;

    home.username = lib.mkDefault "rebmit";
    home.homeDirectory = lib.mkDefault "/home/rebmit";

    home.persistence."/persist/home/${config.home.username}" = {
      directories = [
        "Documents"
        "Downloads"
        "Pictures"
        "Projects"
        "Workspaces"
        ".ssh"
        ".cache"
        ".local"
      ];
      allowOther = true;
    };

    programs.home-manager.enable = true;

    home.stateVersion = "23.11";
  };
}
