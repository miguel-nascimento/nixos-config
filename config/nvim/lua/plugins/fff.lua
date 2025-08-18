return {
  {
    'dmtrKovalenko/fff.nvim',
    build = 'nix run .#release',
    opts = {
      -- pass here all the options
    },
    keys = {
      {
        '<leader>sf',
        function()
          require('fff').find_files()
        end,
        desc = '[S]earch [F]iles',
      },
      {
        '<leader>sp',
        function()
          require('fff').find_in_git_root()
        end,
        desc = '[S]earch [P]roject Files (Git Files)',
      },
    },
  },
}
