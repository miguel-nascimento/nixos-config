return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
    },
    config = function()
      local treesitter = require 'nvim-treesitter'
      treesitter.setup {}
      local languages = {
        'tsx',
        'typescript',
        'bash',
        'html',
        'javascript',
        'css',
        'lua',
        'json',
        'markdown',
        'markdown_inline',
        'prisma',
        'vim',
        'vimdoc',
        'c',
        'nix',
        'go',
        'gomod',
        'zig',
      }
      treesitter.install(languages)

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('UserTreesitter', { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
          if lang and vim.list_contains(languages, lang) and vim.treesitter.language.add(lang) then
            vim.treesitter.start(args.buf, lang)
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
