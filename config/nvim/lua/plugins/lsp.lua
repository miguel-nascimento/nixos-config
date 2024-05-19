-- Kindly stolen from dmulroy nvim kickstart.nix <3
return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost' },
    cmd = { 'LspInfo', 'LspInstall', 'LspUninstall', 'Mason' },
    dependencies = {
      -- Plugin and UI to automatically install LSPs to stdpath
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      'hrsh7th/cmp-nvim-lsp',
      -- Install none-ls for diagnostics, code actions, and formatting
      'nvimtools/none-ls.nvim',
      'nvimtools/none-ls-extras.nvim',
      -- Install neodev for better nvim configuration and plugin authoring via lsp configurations
      'folke/neodev.nvim',
      -- Neoconf so we can share config with co-workers (config-as-json) 🫂
      'folke/neoconf.nvim',
      -- Progress/Status update for LSP
      { 'j-hui/fidget.nvim', tag = 'v1.0.0' },
      'pmizio/typescript-tools.nvim',
    },
    config = function()
      local null_ls = require 'null-ls'
      local map_lsp_keybinds = require('user.keymaps').map_lsp_keybinds -- Has to load keymaps before pluginslsp

      -- Use neodev to configure lua_ls in nvim directories - must load before lspconfig
      require('neodev').setup()

      -- Setup mason so it can manage 3rd party LSP servers
      require('mason').setup()

      -- Configure mason to auto install servers
      require('mason-lspconfig').setup {
        automatic_installation = true,
      }

      -- Setup neoconf to have config-as-json support
      require('neoconf').setup()

      -- LSP servers to install (see list here: https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers )
      local servers = {
        bashls = {},
        -- clangd = {},
        cssls = {},
        html = {},
        jsonls = {},
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enabled = false },
              globals = { 'vim' },
            },
          },
        },
        marksman = {},
        nil_ls = {},
        prismals = {},
        tailwindcss = {
          -- filetypes = { "reason" },
        },
        eslint_d = {},
        tsserver = {
          settings = {
            experimental = {
              enableProjectDiagnostics = true,
            },
          },
        },
        rust_analyzer = {},
        gopls = {},
        -- TODO: add more Rust stuff! https://github.com/mrcjkb/rustaceanvim
      }

      -- nvim-cmp supports additional completion capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local default_capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      local on_attach = function(client, buffer_number)
        local format_fn = function(_)
          vim.lsp.buf.format {
            filter = function(format_client)
              -- Use Prettier to format TS/JS if it's available
              return format_client.name ~= 'tsserver' or not null_ls.is_registered 'prettier'
            end,
          }
        end

        -- Create a command `:Format` local to the LSP buffer
        vim.api.nvim_buf_create_user_command(buffer_number, 'Format', format_fn,
          { desc = 'LSP: Format current buffer with LSP' })

        -- https://github.com/nvimtools/none-ls.nvim/wiki/Formatting-on-save
        local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
        if client.supports_method 'textDocument/formatting' then
          vim.api.nvim_clear_autocmds {
            group = augroup,
            buffer = buffer_number,
          }
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = augroup,
            buffer = buffer_number,
            callback = format_fn,
          })
        end

        -- Pass the current buffer to map lsp keybinds
        map_lsp_keybinds(buffer_number)
      end

      -- Iterate over our servers and set them up
      for name, config in pairs(servers) do
        if name == 'tsserver' then
          require('typescript-tools').setup {
            on_attach = on_attach,
          }
        else
          require('lspconfig')[name].setup {
            capabilities = default_capabilities,
            filetypes = config.filetypes,
            on_attach = on_attach,
            settings = config.settings,
          }
        end
      end

      -- Configure LSP linting, formatting, diagnostics, and code actions
      local formatting = null_ls.builtins.formatting
      local diagnostics = null_ls.builtins.diagnostics
      local code_actions = null_ls.builtins.code_actions

      null_ls.setup {
        sources = {
          -- formatting
          formatting.prettierd,
          formatting.stylua,
          formatting.rustfmt,
          formatting.gofumpt,
          formatting.goimports,
          formatting.goimports_reviser,
          require("none-ls.diagnostics.eslint"),
          require("none-ls.code_actions.eslint")
          -- -- diagnostics
          -- require('none-ls.diagnostics.eslint_d').with {
          --   condition = function(utils)
          --     return utils.root_has_file {
          --       '.eslintrc.js',
          --       '.eslintrc.cjs',
          --       '.eslintrc.json',
          --     }
          --   end,
          -- },
          -- require('none-ls.code_actions.eslint_d').with {
          --   condition = function(utils)
          --     return utils.root_has_file {
          --       '.eslintrc.js',
          --       '.eslintrc.cjs',
          --       '.eslintrc.json',
          --     }
          --   end,
          -- },

          -- code actions
          -- Gitsign action: I would love to use it, but it always mess with
          -- code actions order. I want the LSP first, them null-ls.
          -- I will probably face the same issue with eslint.
          -- code_actions.gitsigns,
          -- code_actions.eslint_d.with {
          --   condition = function(utils)
          --     return utils.root_has_file {
          --       '.eslintrc.js',
          --       '.eslintrc.cjs',
          --       '.eslintrc.json',
          --     }
          --   end,
          -- },
        },
      }
    end,
  },
}
