return {
	"kndndrj/nvim-dbee",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	build = function()
		-- Build the binary if needed
		require("dbee").install()
	end,
	config = function()
		local dbee = require("dbee")

		-- Initialize with minimal config
		dbee.setup({
			-- UI configuration
			ui = {
				window = {
					width = 0.85, -- 85% of screen width
					height = 0.85, -- 85% of screen height
				},
				-- Use minimal UI without unnecessary elements
				layout = "default",
			},
			-- Sources: Define your database connections here
			sources = {
				-- Example: PostgreSQL
				-- {
				--   name = "Local PostgreSQL",
				--   type = "postgresql",
				--   url = "postgresql://user:pass@localhost:5432/dbname",
				-- },
			},
		})

		-- Key mappings (minimal but powerful)
		vim.keymap.set("n", "<leader>do", dbee.open, { desc = "DBee: Open UI" })
		vim.keymap.set("n", "<leader>dc", dbee.close, { desc = "DBee: Close UI" })
		vim.keymap.set("n", "<leader>dt", dbee.toggle, { desc = "DBee: Toggle UI" })

		-- Quick execution commands (when UI is open)
		vim.keymap.set("n", "<leader>dx", function()
			-- Execute current query (when in SQL buffer)
			if vim.bo.filetype == "sql" then
				dbee.execute(vim.fn.line("."), vim.fn.line("."))
			else
				vim.notify("Not in SQL buffer", vim.log.levels.WARN)
			end
		end, { desc = "DBee: Execute current line" })

		vim.keymap.set("v", "<leader>dx", function()
			-- Execute visual selection
			if vim.bo.filetype == "sql" then
				local start_line = vim.fn.line("v")
				local end_line = vim.fn.line(".")
				dbee.execute(start_line, end_line)
			else
				vim.notify("Not in SQL buffer", vim.log.levels.WARN)
			end
		end, { desc = "DBee: Execute visual selection" })

		-- Quick connection management
		vim.keymap.set("n", "<leader>AA", dbee.add_source, { desc = "DBee: Add connection" })
		vim.keymap.set("n", "<leader>AL", dbee.list_sources, { desc = "DBee: List connections" })

		-- Query history navigation
		vim.keymap.set("n", "<leader>AN", dbee.next_history, { desc = "DBee: Next query" })
		vim.keymap.set("n", "<leader>AP", dbee.prev_history, { desc = "DBee: Previous query" })
	end,
}
