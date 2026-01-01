return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	event = "VeryLazy",
	config = function()
		require("nvim-treesitter.configs").setup({
			textobjects = {

				-- =====================
				-- SELECT TEXT OBJECTS
				-- =====================
				select = {
					enable = true,
					lookahead = true, -- jump forward automatically

					keymaps = {
						-- functions
						["af"] = "@function.outer",
						["if"] = "@function.inner",

						-- classes
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",

						-- blocks (if / for / while / try)
						["ab"] = "@block.outer",
						["ib"] = "@block.inner",

						-- parameters / arguments
						["aa"] = "@parameter.outer",
						["ia"] = "@parameter.inner",

						-- calls (function calls)
						["am"] = "@call.outer",
						["im"] = "@call.inner",
					},
				},

				-- =====================
				-- MOVE BETWEEN OBJECTS
				-- =====================
				move = {
					enable = true,
					set_jumps = true,

					goto_next_start = {
						["]f"] = "@function.outer",
						["]c"] = "@class.outer",
						["]b"] = "@block.outer",
					},
					goto_previous_start = {
						["[f"] = "@function.outer",
						["[c"] = "@class.outer",
						["[b"] = "@block.outer",
					},
				},

				-- =====================
				-- SWAP PARAMETERS
				-- =====================
				swap = {
					enable = true,
					swap_next = {
						["<leader>sa"] = "@parameter.inner",
					},
					swap_previous = {
						["<leader>sA"] = "@parameter.inner",
					},
				},
			},
		})
	end,
}
