return {
  -- Oil to move stuff around -- maybe we can keep it as our viewer
  {
    'stevearc/oil.nvim',
    opts = {},
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup {}
    end,
  },
  -- Neo tree -- oil is good to move stuff, but comfy view - I know what I'm safe when I see a treeview
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function()
      require('neo-tree').setup {
        filesystem = {
          hijack_netrw_behavior = 'disabled', -- Oil will be the "netrw" one
          follow_current_file = {
            enabled = true,
          },
        },
        window = {
          mappings = {
            ['<C-c>'] = 'close_window', -- Standard way to close stuff?
          },
        },
      }
    end,
  },
}
