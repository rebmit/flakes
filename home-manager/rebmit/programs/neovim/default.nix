{
  mylib,
  pkgs,
  ...
}: {
  imports = mylib.getItemPaths ./. "default.nix";

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
    ];

    extraConfig = ''
      :source ${./nvim.lua}
    '';
  };
}
