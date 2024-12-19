return {
  -- Hmm I dont think I'm using Fugitive that much. But I will keep it here
  -- When I need it, I will have it.
  { 'tpope/vim-fugitive', event = 'VeryLazy' },
  { 'tpope/vim-rhubarb', event = 'VeryLazy' },
  {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    config = function()
      require('gitsigns').setup {
        current_line_blame = true,
      }
    end,
  },
  -- I should add Toggleterm.nvim and use lazygit on it
  -- or just use tmux xD
}
