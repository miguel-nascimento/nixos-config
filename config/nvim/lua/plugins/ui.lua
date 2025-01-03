-- UI around nvim itself: icons, statusline, UI kit, theme...
return {
  -- dressing nvim
  {
    'stevearc/dressing.nvim',
    lazy = true,
    init = function()
      vim.ui.select = function(...)
        require('lazy').load { plugins = { 'dressing.nvim' } }
        return vim.ui.select(...)
      end
      vim.ui.input = function(...)
        require('lazy').load { plugins = { 'dressing.nvim' } }
        return vim.ui.input(...)
      end
    end,
  },
  -- statusline
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      local function truncate_branch_name(branch)
        if not branch or branch == '' then
          return ''
        end

        -- Match the branch name to the specified format
        local user, team, ticket_number = string.match(branch, '^(%w+)/(%w+)%-(%d+)')

        -- If the branch name matches the format, display {user}/{team}-{ticket_number}, otherwise display the full branch name
        if ticket_number then
          return user .. '/' .. team .. '-' .. ticket_number
        else
          return branch
        end
      end

      -- See `:help lualine.txt`
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_b = {
            { 'branch', icon = '', fmt = truncate_branch_name },
            'diff',
            'diagnostics',
          },
          lualine_c = {
            { 'filename', path = 1 },
          },
          lualine_x = {
            'filetype',
          },
        },
      }
    end,
  },
  -- icons
  { 'nvim-tree/nvim-web-devicons', lazy = true },
  -- theme
  {
    'projekt0n/github-nvim-theme',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require('github-theme').setup {
        -- ...
      }

      vim.cmd 'colorscheme github_dark_default'
    end,
  },
}
