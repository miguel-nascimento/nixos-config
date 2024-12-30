return {
  {
    'stevearc/quicker.nvim',
    keys = {
      {
        '<leader>q',
        function()
          require('quicker').toggle { focus = true }
        end,
        desc = 'quicker.nvim',
      },
    },
    event = 'FileType qf',
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {
      keys = {
        {
          '>',
          function()
            require('quicker').expand { before = 2, after = 5, add_to_existing = true }
          end,
          desc = 'Expand quickfix context',
        },
        {
          '<',
          function()
            require('quicker').collapse()
          end,
          desc = 'Collapse quickfix context',
        },
      },
    },
  },
}
