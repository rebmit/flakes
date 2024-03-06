{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  xdg.configFile = {
    "nvim" = {
      source = pkgs.vimPlugins.nvchad;
      recursive = true;
    };

    "nvim/lua/custom" = {
      source = ./nvchad;
      recursive = true;
    };
  };
}
