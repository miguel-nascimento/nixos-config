return {
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    ---@module 'which-key'
    ---@type wk.Opts
    opts = {
      preset = 'modern',
      -- Show the popup for every prefix in normal, visual, operator-pending and select mode
      triggers = {
        { '<auto>', mode = 'nxso' },
      },
      spec = {
        { '<leader>c', group = '[C]ode' },
        { '<leader>f', group = '[F]ile' },
        { '<leader>i', group = '[I]nlay' },
        { '<leader>n', group = '[N]o highlight' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
      },
    },
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show { global = false }
        end,
        desc = 'Buffer local keymaps (which-key)',
      },
    },
  },
}
