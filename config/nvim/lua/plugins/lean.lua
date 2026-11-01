return {
  {
    'Julian/lean.nvim',
    event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },
    dependencies = {
      'saghen/blink.cmp',
      'nvim-telescope/telescope.nvim',
    },
    ---@type lean.Config
    init = function()
      vim.g.lean_config = { mappings = true }
    end,
  },
}
