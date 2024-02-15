return {
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
  },
  -- using comment.nvim only for block comments -- planning to switch to mini-comment if I not use it on daily usage
  {
    'numToStr/Comment.nvim',
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    config = function ()
      require('Comment').setup {
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      }
    end
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  }
}
