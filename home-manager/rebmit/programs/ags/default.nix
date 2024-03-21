{ inputs, ... }: {
  imports = [
    inputs.ags.homeManagerModules.default

    ./style.nix
  ];

  programs.ags = {
    enable = true;
  };

  xdg.configFile."ags/components" = {
    source = ./components;
    recursive = true;
  };

  xdg.configFile."ags/config.js" = {
    source = ./config.js;
  };
}
