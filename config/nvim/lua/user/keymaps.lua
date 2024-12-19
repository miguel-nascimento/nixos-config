local M = {}
local function bind(op, outer_opts)
  outer_opts = vim.tbl_extend('force', { noremap = true, silent = true }, outer_opts or {})

  return function(lhs, rhs, opts)
    opts = vim.tbl_extend('force', outer_opts, opts or {})
    vim.keymap.set(op, lhs, rhs, opts)
  end
end

local map = bind ''
local nmap = bind('n', { noremap = false })
local nnoremap = bind 'n'
local vnoremap = bind 'v'
local xnoremap = bind 'x'
local inoremap = bind 'i'
local tnoremap = bind 't'

-- Center buffer while navigating
nnoremap('<C-u>', '<C-u>zz')
nnoremap('<C-d>', '<C-d>zz')
nnoremap('{', '{zz')
nnoremap('}', '}zz')
nnoremap('N', 'Nzz')
nnoremap('n', 'nzz')
nnoremap('G', 'Gzz')
nnoremap('gg', 'ggzz')
nnoremap('<C-i>', '<C-i>zz')
nnoremap('<C-o>', '<C-o>zz')
nnoremap('%', '%zz')
nnoremap('*', '*zz')
nnoremap('#', '#zz')

-- Press 'U' for redo
nnoremap('U', '<C-r>')

-- Leader stuff
-- Oil
nnoremap('<leader>fe', function()
  require('oil').open_float()
end, { desc = '[F]ile [E]xplorer' })

-- Neotree (I could do this with require instead of cmd argh!)
nnoremap('<leader>ft', '<cmd>Neotree position=right<cr>', { desc = '[F]ile [T]ree' })

-- Turn off highlighted results
nnoremap('<leader>no', '<cmd>noh<cr>')

-- Diagnostic keymaps
nnoremap('<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
nnoremap('<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Telescope
nnoremap('<leader>sf', function()
  -- Fine to find_files due to the `file_ignore_patterns` in telescope config
  require('telescope.builtin').find_files { hidden = true }
end, { desc = '[S]earch [F]iles' })

nnoremap('<leader>sp', function()
  require('telescope.builtin').git_files { hidden = true }
end, { desc = '[S]earch [P]roject Files (Git Files)' })

nnoremap('<leader><leader>', function()
  require('telescope.builtin').buffers { hidden = true }
end, { desc = '[ ] Find existing buffers' })

nnoremap('<leader>sc', function()
  require('telescope.builtin').live_grep { hidden = true }
end, { desc = '[S]earch [C]ode' })

nnoremap('<leader>sw', function()
  require('telescope.builtin').grep_string { hidden = true }
end, { desc = '[S]earch Current [W]ord' })

nnoremap('<leader>ss', function()
  require('telescope.builtin').lsp_document_symbols { hidden = true }
end, { desc = '[S]earch Document [S]ymbols' })

-- nnoremap('<leader>sq', function()
--   require('telescope.builtin').quickfix { hidden = true }
-- end, { desc = '[S]earch [Q]uickfix' })

-- LSP keybinds
M.map_lsp_keybinds = function(buffer_number)
  nnoremap('<leader>rn', vim.lsp.buf.rename, { desc = 'LSP: [R]e[n]ame', buffer = buffer_number })
  nnoremap('<leader>ca', vim.lsp.buf.code_action, { desc = 'LSP: [C]ode [A]ction', buffer = buffer_number })
  nnoremap('gd', vim.lsp.buf.definition, { desc = 'LSP: [G]oto [D]efinition', buffer = buffer_number })

  -- Telescope LSP keybinds --
  nnoremap('gr', require('telescope.builtin').lsp_references, { desc = 'LSP: [G]oto [R]eferences', buffer = buffer_number })
  nnoremap('gI', require('telescope.builtin').lsp_implementations, { desc = 'LSP: [G]oto [I]mplementation', buffer = buffer_number })
  -- See `:help K` for why this keymap
  nnoremap('K', vim.lsp.buf.hover, { desc = 'LSP: Hover Documentation', buffer = buffer_number })
  nnoremap('<leader>k', vim.lsp.buf.signature_help, { desc = 'LSP: Signature Documentation', buffer = buffer_number })
  inoremap('<C-k>', vim.lsp.buf.signature_help, { desc = 'LSP: Signature Documentation', buffer = buffer_number })

  -- Lesser used LSP functionality
  nnoremap('gD', vim.lsp.buf.declaration, { desc = 'LSP: [G]oto [D]eclaration', buffer = buffer_number })
  nnoremap('<leader>D', vim.lsp.buf.type_definition, { desc = 'LSP: [T]ype [D]efinition', buffer = buffer_number })
  nnoremap('<leader>ih', function()
    local prev_state = vim.lsp.inlay_hint.is_enabled { bufnr = buffer_number }
    vim.lsp.inlay_hint.enable(not prev_state)
  end, { desc = 'LSP: [I]nline [H]ints', buffer = buffer_number })
end

-- TODO: git keybindings

-- Visual --
-- Disable Space bar since it'll be used as the leader key
vnoremap('<space>', '<nop>')

return M
