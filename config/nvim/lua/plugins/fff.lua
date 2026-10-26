return {
  {
    'dmtrKovalenko/fff.nvim',
    build = function()
      require('fff.download').download_or_build_binary()
    end,
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
      {
        '<leader>sc',
        function()
          require('fff').live_grep()
        end,
        desc = '[S]earch [C]ode',
      },
    },
  },
}
