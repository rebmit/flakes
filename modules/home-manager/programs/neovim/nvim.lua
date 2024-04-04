--
-- general
-- 

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.smarttab = true

vim.opt.timeoutlen = 500
vim.opt.scrolloff = 5

--
-- mappings
--

--- set <leader> as space, ; as :
vim.g.mapleader = ' '
vim.api.nvim_set_keymap('', ';', ':', { noremap = true })

--- save and quit
vim.api.nvim_set_keymap('', 'S', ':w<CR>', { noremap = true })
vim.api.nvim_set_keymap('', 'Q', ':q<CR>', { noremap = true })

--- cursor movement
vim.api.nvim_set_keymap('', 'J', '5j', { noremap = true })
vim.api.nvim_set_keymap('', 'K', '5k', { noremap = true })
vim.api.nvim_set_keymap('', 'H', '5h', { noremap = true })
vim.api.nvim_set_keymap('', 'L', '5l', { noremap = true })

vim.api.nvim_set_keymap('', '<C-j>', '5<C-e>', { noremap = true })
vim.api.nvim_set_keymap('', '<C-k>', '5<C-y>', { noremap = true })
vim.api.nvim_set_keymap('', '<C-h>', '0', { noremap = true })
vim.api.nvim_set_keymap('', '<C-l>', '$', { noremap = true })

--- window management
vim.api.nvim_set_keymap('', '<leader>h', '<C-w>h', { noremap = true })
vim.api.nvim_set_keymap('', '<leader>j', '<C-w>j', { noremap = true })
vim.api.nvim_set_keymap('', '<leader>k', '<C-w>k', { noremap = true })
vim.api.nvim_set_keymap('', '<leader>l', '<C-w>l', { noremap = true })

vim.api.nvim_set_keymap('', 'sh', ':set nosplitright<CR>:vsplit<CR>', { noremap = true })
vim.api.nvim_set_keymap('', 'sj', ':set splitbelow<CR>:split<CR>', { noremap = true })
vim.api.nvim_set_keymap('', 'sk', ':set nosplitbelow<CR>:split<CR>', { noremap = true })
vim.api.nvim_set_keymap('', 'sl', ':set splitright<CR>:vsplit<CR>', { noremap = true })

vim.api.nvim_set_keymap('', '<up>', ':res +5<CR>', { noremap = true })
vim.api.nvim_set_keymap('', '<down>', ':res -5<CR>', { noremap = true })
vim.api.nvim_set_keymap('', '<left>', ':vertical resize -5<CR>', { noremap = true })
vim.api.nvim_set_keymap('', '<right>', ':vertical resize +5<CR>', { noremap = true })

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local servers = { 'nil_ls' }

for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {
    capabilities = capabilities,
  }
end

local luasnip = require 'luasnip'
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

require('which-key').setup {
}

require('leap').add_default_mappings()

require('nvim-autopairs').setup()

require('nvim-tree').setup()
