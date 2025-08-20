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

      -- Function to detect if system is in light mode (macOS only)
      local function is_light_mode()
        -- Only check system theme on macOS
        if vim.fn.has 'mac' == 0 then
          return false -- default to dark mode on non-macOS systems
        end

        local handle = io.popen 'defaults read -g AppleInterfaceStyle 2>/dev/null'
        if handle then
          local result = handle:read '*a'
          handle:close()
          -- If AppleInterfaceStyle is not set or doesn't contain 'Dark', it's light mode
          return result:match 'Dark' == nil
        end
        return false -- default to dark mode if detection fails
      end

      -- Function to set theme based on system appearance
      local function set_theme_from_system()
        if is_light_mode() then
          vim.cmd 'colorscheme github_light_default'
        else
          vim.cmd 'colorscheme github_dark_default'
        end
      end

      -- Set initial theme
      set_theme_from_system()

      -- Create autocommand to check theme when Neovim gains focus
      vim.api.nvim_create_autocmd({ 'FocusGained', 'VimEnter' }, {
        group = vim.api.nvim_create_augroup('SystemThemeSync', { clear = true }),
        callback = set_theme_from_system,
      })
    end,
  },
}
