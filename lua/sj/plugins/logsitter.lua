return {
	"gaelph/logsitter.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "javascript", "typescript" },
			highlight = { enable = true },
		})

		require("logsitter").setup({
			path_format = "default",
			prefix = "[LS] ->",
			separator = "->",
		})

		local map = vim.api.nvim_set_keymap
		local opts = { noremap = true, silent = true }

		map(
			"n",
			"<leader>la",
			':lua require("logsitter.commands").log_line()<CR>',
			vim.tbl_extend("force", opts, { desc = "Logsitter: Log current line" })
		)
		map(
			"n",
			"<leader>lf",
			':lua require("logsitter.commands").log_function()<CR>',
			vim.tbl_extend("force", opts, { desc = "Logsitter: Log current function" })
		)
		map(
			"v",
			"<leader>lv",
			':lua require("logsitter.commands").log_selection()<CR>',
			vim.tbl_extend("force", opts, { desc = "Logsitter: Log visual selection" })
		)
	end,
}
