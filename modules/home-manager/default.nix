{
  default = { mylib, lib, inputs, config, ... }: {
    imports = [
      inputs.impermanence.nixosModules.home-manager.impermanence
      inputs.ags.homeManagerModules.default
      inputs.nix-colors.homeManagerModules.default
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
