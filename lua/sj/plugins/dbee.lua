-- ~/.config/nvim/lua/sj/core/custom/ai/dbee.lua
return {
	"kndndrj/nvim-dbee",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local db = require("dbee")

		-- Example Postgres connection

		db.setup({
			connections = {
				local_pg = {
					driver = "postgres",
					url = "postgres://postgres:sj@localhost:5432/postgre-basics",
				},
			},
			default_connection = "local_pg",
		})

		local opts = { noremap = true, silent = true }

		-- Keymaps prefixed with <leader>D
		vim.api.nvim_set_keymap("n", "<leader>DC", "<cmd>DBEEConnect<CR>", opts) -- Connect
		vim.api.nvim_set_keymap("n", "<leader>DD", "<cmd>DBEEDisconnect<CR>", opts) -- Disconnect
		vim.api.nvim_set_keymap("n", "<leader>DT", "<cmd>DBEETables<CR>", opts) -- List Tables
		vim.api.nvim_set_keymap("n", "<leader>DQ", "<cmd>DBEEQuery<CR>", opts) -- Run Query
		vim.api.nvim_set_keymap("n", "<leader>DR", "<cmd>DBEEResults<CR>", opts) -- Toggle Results
	end,
}
