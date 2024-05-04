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
vim.opt.termguicolors = true

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

vim.api.nvim_set_keymap('', '<S-tab>', ':bprev<CR>', { noremap = true })
vim.api.nvim_set_keymap('', '<tab>', ':bnext<CR>', { noremap = true })

--
-- plugins
--

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require('lspconfig')
local servers = { 'nil_ls', 'pyright', 'rust_analyzer' }

for _, lsp in pairs(servers) do
  lspconfig[lsp].setup {
    capabilities = capabilities,
    settings = {
      ['nil'] = {
        formatting = {
          command = { 'nixpkgs-fmt' }
        }
      },
    },
  }
end

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

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

local nvim_tree = require('nvim-tree')
local nvim_tree_api = require('nvim-tree.api')
nvim_tree.setup({
  filters = {
    dotfiles = false,
  },
  disable_netrw = true,
  hijack_netrw = true,
  hijack_cursor = true,
  hijack_unnamed_buffer_when_opening = false,
  sync_root_with_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = false,
  },
  view = {
    adaptive_size = false,
    side = "left",
    width = 30,
    preserve_window_proportions = true,
  },
  git = {
    enable = true,
    ignore = true,
  },
  filesystem_watchers = {
    enable = true,
  },
  actions = {
    open_file = {
      resize_window = true,
    },
  },
  on_attach = function (bufnr)
    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    nvim_tree_api.config.mappings.default_on_attach(bufnr)
    vim.keymap.set('n', '<C-t>', nvim_tree_api.tree.change_root_to_parent, opts('Up'))
  end
})

vim.keymap.set('n', '<leader>tt', nvim_tree_api.tree.toggle, { noremap = true, desc = "toggle nvim-tree" })

require('lualine').setup {
  sections = {
    lualine_x = { 'lsp_progress', 'encoding' },
  },
}

require('bufferline').setup{}

require('telescope').setup{}
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
