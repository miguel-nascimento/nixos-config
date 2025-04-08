-- TODO:
--     require 'none-ls.diagnostics.eslint',
--     require 'none-ls.code_actions.eslint',
return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost' },
    cmd = { 'LspInfo', 'LspInstall', 'LspUninstall', 'Mason' },
    dependencies = {
      'saghen/blink.cmp',
      -- Plugin and UI to automatically install LSPs to stdpath
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Install none-ls for diagnostics, code actions, and formatting
      'nvimtools/none-ls.nvim',
      'nvimtools/none-ls-extras.nvim',
      -- Install lazydev for better nvim configuration and plugin authoring via lsp configurations
      {
        'folke/lazydev.nvim',
        ft = 'lua', -- only load on lua files
        opts = {
          library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
          },
        },
      },
      { 'Bilal2453/luvit-meta', lazy = true }, -- optional `vim.uv` typings
      -- Neoconf so we can share config with co-workers (config-as-json) 🫂
      'folke/neoconf.nvim',
      -- Progress/Status update for LSP
      { 'j-hui/fidget.nvim', tag = 'v1.0.0' },
      'pmizio/typescript-tools.nvim',
    },
    config = function()
      local map_lsp_keybinds = require('user.keymaps').map_lsp_keybinds -- Has to load keymaps before pluginslsp

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
        prismals = {},
        tailwindcss = {
          -- filetypes = { "reason" },
        },
        tsserver = {
          settings = {
            experimental = {
              enableProjectDiagnostics = true,
            },
          },
        },
        rust_analyzer = {},
        gopls = {},
        nixd = {
          settings = {
            nixd = {
              formatting = {
                command = { 'nixfmt' },
              },
            },
          },
        },
        ocamllsp = {},
        basedpyright = {},
        zls = {},
        -- TODO: add more Rust stuff! https://github.com/mrcjkb/rustaceanvim
      }

      -- local default_capabilities = vim.lsp.protocol.make_client_capabilities()
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local on_attach = function(client, buffer_number)
        -- Pass the current buffer to map lsp keybinds
        map_lsp_keybinds(buffer_number)

        local handle_inline_hint = function()
          if client.server_capabilities.inlayHintProvider then
            local inlay_hints_group = vim.api.nvim_create_augroup('InlineHint', { clear = true })
            vim.api.nvim_create_autocmd('InsertEnter', {
              group = inlay_hints_group,
              buffer = buffer_number,
              callback = function()
                vim.lsp.inlay_hint.enable(false, { bufnr = buffer_number })
              end,
            })
            vim.api.nvim_create_autocmd('InsertLeave', {
              group = inlay_hints_group,
              buffer = buffer_number,
              callback = function()
                vim.lsp.inlay_hint.enable(true, { bufnr = buffer_number })
              end,
            })

            -- Initial inlay hint display.
            local mode = vim.api.nvim_get_mode().mode
            if mode == 'n' or mode == 'v' then
              vim.lsp.inlay_hint.enable(true, { bufnr = buffer_number })
            end
          end
        end
        handle_inline_hint()
      end

      -- Iterate over our servers and set them up
      for name, config in pairs(servers) do
        if name == 'tsserver' then
          require('typescript-tools').setup {
            on_attach = on_attach,
          }
        else
          require('lspconfig')[name].setup {
            capabilities = capabilities,
            filetypes = config.filetypes,
            on_attach = on_attach,
            settings = config.settings,
          }
        end
      end
    end,
  },
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    -- This will provide type hinting with LuaLS
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        rust = { 'rustfmt' },
        python = { 'ruff_format', 'ruff_organize_imports' },
        javascript = { 'prettierd' },
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        markdown = { 'prettierd', 'prettier', stop_after_first = true },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        ocaml = { 'ocamlformat' },
        go = { 'gofumpt', 'goimports', 'goimports_reviser' },
        zig = { 'zigfmt' },
      },
      default_format_opts = {
        lsp_format = 'fallback',
      },
      format_on_save = { timeout_ms = 500 },
      formatters = {
        prettierd = {
          condition = function()
            return vim.loop.fs_realpath '.prettierrc.js' ~= nil or vim.loop.fs_realpath '.prettierrc.mjs' ~= nil
          end,
        },
      },
    },
    init = function()
      vim.api.nvim_create_user_command('Format', function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ['end'] = { args.line2, end_line:len() },
          }
        end
        require('conform').format { async = true, lsp_format = 'fallback', range = range }
      end, { range = true })
      -- If you want the formatexpr, here is the place to set it
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}
