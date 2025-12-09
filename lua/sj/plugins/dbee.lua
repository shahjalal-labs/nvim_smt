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

		-- Initialize with your PostgreSQL connection
		dbee.setup({
			-- UI configuration
			ui = {
				window = {
					width = 0.85, -- 85% of screen width
					height = 0.85, -- 85% of screen height
				},
			},
			-- Sources: Define your database connections here
			sources = {
				{
					name = "PostgreSQL Basics",
					type = "postgresql",
					url = "postgres://postgres:sj@localhost:5432/postgre-basics",
				},
				-- You can add more connections here
				-- {
				--   name = "Another DB",
				--   type = "postgresql",
				--   url = "postgres://user:pass@localhost:5432/otherdb",
				-- },
			},
		})

		-- Key mappings (minimal but powerful)
		vim.keymap.set("n", "<leader>dt", dbee.toggle, { desc = "DBee: Toggle UI" })
		vim.keymap.set("n", "<leader>do", dbee.open, { desc = "DBee: Open UI" })
		vim.keymap.set("n", "<leader>dc", dbee.close, { desc = "DBee: Close UI" })

		-- Quick execution commands
		vim.keymap.set("n", "<leader>dx", function()
			if vim.bo.filetype == "sql" then
				dbee.execute(vim.fn.line("."), vim.fn.line("."))
			else
				vim.notify("Not in SQL buffer", vim.log.levels.WARN)
			end
		end, { desc = "DBee: Execute current line" })

		vim.keymap.set("v", "<leader>dx", function()
			if vim.bo.filetype == "sql" then
				local start_line = vim.fn.line("v")
				local end_line = vim.fn.line(".")
				dbee.execute(start_line, end_line)
			else
				vim.notify("Not in SQL buffer", vim.log.levels.WARN)
			end
		end, { desc = "DBee: Execute visual selection" })

		-- Quick connection management
		vim.keymap.set("n", "<leader>da", dbee.add_source, { desc = "DBee: Add connection" })
		vim.keymap.set("n", "<leader>dl", dbee.list_sources, { desc = "DBee: List connections" })

		-- Query history
		vim.keymap.set("n", "<leader>dn", dbee.next_history, { desc = "DBee: Next query" })
		vim.keymap.set("n", "<leader>dp", dbee.prev_history, { desc = "DBee: Previous query" })

		-- Quick results export
		vim.keymap.set("n", "<leader>de", function()
			vim.ui.select({ "json", "csv", "yaml", "xml" }, { prompt = "Export format:" }, function(format)
				if format then
					require("dbee").export(format)
				end
			end)
		end, { desc = "DBee: Export results" })

		-- Switch between connections quickly
		vim.keymap.set("n", "<leader>ds", function()
			local sources = require("dbee").get_sources()
			local choices = {}
			for _, source in ipairs(sources) do
				table.insert(choices, source.name)
			end

			if #choices == 0 then
				vim.notify("No connections available", vim.log.levels.WARN)
				return
			end

			vim.ui.select(choices, { prompt = "Switch to connection:" }, function(choice)
				if choice then
					require("dbee").switch_source(choice)
				end
			end)
		end, { desc = "DBee: Switch connection" })
	end,
}
