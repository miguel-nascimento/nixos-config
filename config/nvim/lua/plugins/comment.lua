return {
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = { 'BufReadPost', 'BufNewFile', 'BufWritePre' },
    config = function()
      require('todo-comments').setup {}
    end,
  },
}
