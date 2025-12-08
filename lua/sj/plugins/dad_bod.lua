-- ~/.config/nvim/lua/plugins/db.lua
return {
	"tpope/vim-dadbod",
	dependencies = {
		"kristijanhusak/vim-dadbod-ui",
		"kristijanhusak/vim-dadbod-completion",
	},
	cmd = { "DB", "DBUI" },
	keys = {
		-- 🚀 DB UI Operations
		{ "<leader>Du", "<cmd>DBUIToggle<CR>", desc = "Toggle DB UI" },
		{ "<leader>Do", "<cmd>DBUI<CR>", desc = "Open DB UI" },

		-- ⚡ Execute Queries
		{ "<leader>De", "<cmd>DBUIExecQuery<CR>", desc = "Execute Query" },
		{ "<leader>DE", ":DBUIExecQuery<CR>", mode = "v", desc = "Execute Selection" },

		-- 🔧 Connections
		{ "<leader>Dc", "<cmd>DBUIClose<CR>", desc = "Close DB UI" },
		{ "<leader>Dr", "<cmd>DBUIReloadConnections<CR>", desc = "Reload Connections" },

		-- 📊 Results
		{ "<leader>Ds", "<cmd>DBUILastQueryInfo<CR>", desc = "Show Last Query" },
		{ "<leader>Df", "<cmd>DBUIFindBuffer<CR>", desc = "Find Query Buffer" },
	},
	config = function()
		-- 🎯 Essential Settings
		vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
		vim.g.db_ui_use_nerd_fonts = 1
		vim.g.db_ui_auto_execute_table_helpers = 1

		-- ⚡ DB URL Pattern
		vim.cmd([[
      let g:dbs = {
      \ 'postgres': 'postgres://localhost:5432/',
      \ 'mongodb': 'mongodb://localhost:27017/'
      \}
    ]])

		-- 🎪 Quick Connect Commands
		vim.api.nvim_create_user_command("DBPostgres", function(opts)
			local db = opts.args or ""
			vim.cmd("DB postgres://localhost:5432/" .. db)
		end, { nargs = "?", desc = "Connect to PostgreSQL" })

		vim.api.nvim_create_user_command("DBMongo", function(opts)
			local db = opts.args or ""
			vim.cmd("DB mongodb://localhost:27017/" .. db)
		end, { nargs = "?", desc = "Connect to MongoDB" })

		-- 🎯 Additional Keymaps
		vim.keymap.set("n", "<leader>Dp", "<cmd>DBPostgres<CR>", { desc = "Connect PostgreSQL" })
		vim.keymap.set("n", "<leader>Dm", "<cmd>DBMongo<CR>", { desc = "Connect MongoDB" })

		-- ⚡ Auto-commands for SQL files
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "sql",
			callback = function()
				-- Quick execute in SQL files
				vim.keymap.set("n", "<leader>De", "<cmd>DBUIExecQuery<CR>", { buffer = true, desc = "Execute Query" })
				vim.keymap.set("v", "<leader>De", ":DBUIExecQuery<CR>", { buffer = true, desc = "Execute Selection" })
			end,
		})
	end,
}
