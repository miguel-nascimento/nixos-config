return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile' },
    cmd = { 'LspInfo', 'LspInstall', 'LspUninstall', 'Mason' },
    dependencies = {
      'saghen/blink.cmp',
      -- Plugin and UI to automatically install LSPs to stdpath
      'mason-org/mason.nvim',
      'mason-org/mason-lspconfig.nvim',

      -- Install none-ls for diagnostics, code actions, and formatting
      'nvimtools/none-ls.nvim',
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
      { 'j-hui/fidget.nvim', opts = {} },
      'pmizio/typescript-tools.nvim',
    },
    config = function()
      local map_lsp_keybinds = require('user.keymaps').map_lsp_keybinds -- Has to load keymaps before pluginslsp

      -- Setup mason so it can manage 3rd party LSP servers
      require('mason').setup()

      -- Setup neoconf to have config-as-json support
      require('neoconf').setup()

      -- LSP servers to configure (see list here: https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers )
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
              diagnostics = { globals = { 'vim' } },
            },
          },
        },
        marksman = {},
        prismals = {},
        tailwindcss = {},
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

      -- Nix supplies nixd, gopls, zls and ocamllsp; Mason supplies the remaining servers.
      require('mason-lspconfig').setup {
        ensure_installed = {
          'bashls',
          'cssls',
          'html',
          'jsonls',
          'lua_ls',
          'marksman',
          'prismals',
          'tailwindcss',
          'rust_analyzer',
          'basedpyright',
        },
        automatic_enable = false,
      }

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local on_attach = function(_, buffer_number)
        -- Pass the current buffer to map lsp keybinds
        -- Inlay hints stay off by default; toggle them with <leader>ih.
        map_lsp_keybinds(buffer_number)
      end

      -- Configure and enable LSP servers using vim.lsp.config (neovim 0.11+)
      for name, config in pairs(servers) do
        vim.lsp.config(name, {
          capabilities = capabilities,
          filetypes = config.filetypes,
          on_attach = on_attach,
          settings = config.settings,
        })
        vim.lsp.enable(name)
      end

      -- oxlint for linting JS/TS (replaces eslint)
      vim.lsp.enable 'oxlint'

      local function native_typescript_root(bufnr)
        local root = vim.fs.root(bufnr, function(name, path)
          return name == 'node_modules' and vim.fn.filereadable(vim.fs.joinpath(path, 'node_modules/typescript/package.json')) == 1
        end)
        if not root then
          return nil
        end

        local package_path = vim.fs.joinpath(root, 'node_modules/typescript/package.json')
        local ok, package = pcall(function()
          return vim.json.decode(table.concat(vim.fn.readfile(package_path), '\n'))
        end)
        local major = ok and type(package) == 'table' and type(package.version) == 'string' and tonumber(package.version:match '^(%d+)')
        local tsc = vim.fs.joinpath(root, 'node_modules/.bin/tsc')
        if major and major >= 7 and vim.fn.executable(tsc) == 1 then
          return root
        end
      end

      vim.lsp.config('tsc', {
        capabilities = capabilities,
        on_attach = on_attach,
        root_dir = function(bufnr, on_dir)
          local root = native_typescript_root(bufnr)
          if root then
            on_dir(root)
          end
        end,
        cmd = function(dispatchers, config)
          local tsc = vim.fs.joinpath(config.root_dir, 'node_modules/.bin/tsc')
          return vim.lsp.rpc.start({ tsc, '--lsp', '--stdio' }, dispatchers)
        end,
      })
      vim.lsp.enable 'tsc'

      -- typescript-tools uses its own setup for TypeScript 5 and 6.
      require('typescript-tools').setup {
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = function(bufnr, on_dir)
          if not native_typescript_root(bufnr) then
            on_dir(require('typescript-tools.utils').get_root_dir(bufnr))
          end
        end,
      }
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
        javascript = { 'oxfmt' },
        javascriptreact = { 'oxfmt' },
        typescript = { 'oxfmt' },
        typescriptreact = { 'oxfmt' },
        ocaml = { 'ocamlformat' },
        go = { 'gofumpt', 'goimports', 'goimports-reviser' },
        zig = { 'zigfmt' },
      },
      default_format_opts = {
        lsp_format = 'fallback',
      },
      format_on_save = { timeout_ms = 500 },
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
