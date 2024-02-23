return {
  {
    "echasnovski/mini.ai",
    version = false,
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    config = function()
      require("mini.ai").setup()
    end,
  },
  {
    "echasnovski/mini.surround",
    version = false,
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    config = function()
      require("mini.surround").setup()
    end,
  },
}
