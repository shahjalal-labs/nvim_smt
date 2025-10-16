return {
	"3rd/time-tracker.nvim",
	dependencies = {
		"3rd/sqlite.nvim",
	},
	event = "VeryLazy",
	keys = {
		{
			"<leader>tr",
			"<cmd>TimeTracker<CR>",
			desc = "Start time tracking",
		},
	},
	opts = {
		data_file = vim.fn.stdpath("data") .. "/time-tracker.db",
	},
}
