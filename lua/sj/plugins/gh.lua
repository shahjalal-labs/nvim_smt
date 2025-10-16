return {
	-- gh.nvim configuration
	{
		"ldelossa/gh.nvim",
		dependencies = {
			{ "ldelossa/litee.nvim" }, -- Required dependency for gh.nvim
		},
		config = function()
			-- Load litee.nvim (required)
			require("litee.lib").setup()
			-- Load gh.nvim
			require("litee.gh").setup({
				-- Optional: Customize options here
				keymaps = {
					-- Example of default key bindings
					open = "o", -- Open issue/PR details
					close = "q", -- Close current window
					next = "n", -- Go to next issue/PR
					prev = "p", -- Go to previous issue/PR
					comment = "c", -- Add a comment
					approve = "a", -- Approve a PR
					request_changes = "r", -- Request changes
				},
			})
			-- Example of key mappings for gh.nvim commands
			vim.keymap.set("n", "<leader>gi", ":GHIssues<CR>", { desc = "List GitHub Issues" })
			vim.keymap.set("n", "<leader>gp", ":GHPulls<CR>", { desc = "List GitHub Pull Requests" })
			vim.keymap.set("n", "<leader>gr", ":GHRepo<CR>", { desc = "View GitHub Repository" })
			vim.keymap.set("n", "<leader>gn", ":GHNotifications<CR>", { desc = "List GitHub Notifications" })
		end,
	},
}
