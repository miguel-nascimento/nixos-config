return {
  {
    'Julian/lean.nvim',
    event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },
    dependencies = {
      'saghen/blink.cmp',
      'nvim-telescope/telescope.nvim',
    },
    ---@type lean.Config
    opts = {
      mappings = true,
    },
  },
}
