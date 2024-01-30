return {
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = function()
			require("nvim-treesitter.install").update({ with_sync = true })()
		end,
		event = { "BufEnter" },
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"tsx",
					"typescript",
					"bash",
					"html",
					"javascript",
					"css",
					"lua",
					"json",
					"markdown",
					"prisma",
					"vim",
					"c",
					"nix",
				},
				sync_install = false,
				highlight = {
					enable = true,
				},
				indent = {
					enable = true,
				},
				autopairs = {
					enable = true,
				},
				autotag = {
					enable = true,
				},
				-- incremental_selection = {
				-- 	enable = true,
				-- 	keymaps = {
				-- 		init_selection = '<c-space>',
				-- 		node_incremental = '<c-space>',
				-- 		scope_incremental = '<c-s>',
				-- 		node_decremental = '<M-space>',
				-- 	},
				-- },
				-- TODO: textobjects
			})
		end,
	},
}
