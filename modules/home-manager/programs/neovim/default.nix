{ pkgs, config, lib, ... }:
with lib; let
  cfg = config.custom.programs.neovim;
in
{
  options.custom.programs.neovim = {
    enable = mkEnableOption "vim-fork focused on extensibility and usability";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nil
    ];

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      vimdiffAlias = true;

      plugins = with pkgs.vimPlugins; [
        nvim-lspconfig
        nvim-cmp
        cmp-nvim-lsp
        catppuccin-nvim
        luasnip
        which-key-nvim
        leap-nvim
        nvim-autopairs
        nvim-treesitter
        nvim-tree-lua
      ];

      extraConfig = ''
        :colorscheme ${config.colorScheme.slug}

        :source ${./nvim.lua}
      '';
    };
  };
}
